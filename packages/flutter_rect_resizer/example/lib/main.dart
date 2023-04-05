import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rect_resizer/flutter_rect_resizer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Rect resizer demo',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: ChangeNotifierProvider(
          create: (_) => PlaygroundModel(),
          child: const Playground(),
        ),
      ),
    );
  }
}

class PlaygroundModel with ChangeNotifier {
  Rect box = Rect.zero;
  Flip flip = Flip.none;
  Rect clampingBox = Rect.largest;

  bool flipEnabled = true;
  bool clampingEnabled = false;

  void reset(context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width - 300;
    final double height = size.height;
    box = Rect.fromLTWH(
      (width - kInitialWidth) / 2,
      (height - kInitialHeight) / 2,
      kInitialWidth,
      kInitialHeight,
    );
    flip = Flip.none;
    clampingBox = Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width - kSidePanelWidth,
      MediaQuery.of(context).size.height,
    );
    notifyListeners();
  }

  void onRectChanged(Rect rect, Flip flip) {
    box = rect;
    this.flip = flip;
    notifyListeners();
  }

  void onFlipChanged(Flip flip) {
    this.flip = flip;
    notifyListeners();
  }

  void onFlipEnabledChanged(bool enabled) {
    flipEnabled = enabled;
    notifyListeners();
  }

  void setClampingBox(Rect rect, {bool notify = true}) {
    clampingBox = rect;
    if (notify) notifyListeners();
  }

  void flipHorizontally() {
    flip = Flip.fromValue(flip.horizontalValue * -1, flip.verticalValue);
    notifyListeners();
  }

  void flipVertically() {
    flip = Flip.fromValue(flip.horizontalValue, flip.verticalValue * -1);
    notifyListeners();
  }

  void onClampingEnabledChanged(bool enabled) {
    clampingEnabled = enabled;
    notifyListeners();
  }

  void onClampingBoxChanged({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    clampingBox = Rect.fromLTRB(
      left ?? clampingBox.left,
      top ?? clampingBox.top,
      right ?? clampingBox.right,
      bottom ?? clampingBox.bottom,
    );
    notifyListeners();
  }
}

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

const double kSidePanelWidth = 300;
const double kInitialWidth = 400;
const double kInitialHeight = 300;
const double kHandleSize = 12;
const double kStrokeWidth = 1.5;
const Color kGridColor = Color(0x7FC3E8F3);

class _PlaygroundState extends State<Playground> with WidgetsBindingObserver {
  late final PlaygroundModel model = context.read<PlaygroundModel>();

  @override
  void initState() {
    super.initState();

    // This is required to center the box based on screen size when the app
    // starts.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      model.reset(context);
    });

    WidgetsBinding.instance.addObserver(this);
  }

  /// Represents the playground area.
  Rect? playgroundArea;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // This is done to automatically resize clamping rect to the new screen size
    // when the app is resized but only when the clampingRect is already
    // set to the full screen. This is done to avoid the clamping rect to be
    // resized when the user has already resized it.
    playgroundArea ??= Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width - kSidePanelWidth,
      MediaQuery.of(context).size.height,
    );
    if (model.clampingBox == playgroundArea) {
      model.setClampingBox(
        notify: false,
        Rect.fromLTWH(
          0,
          0,
          MediaQuery.of(context).size.width - kSidePanelWidth,
          MediaQuery.of(context).size.height,
        ),
      );
    }
    playgroundArea = Rect.fromLTWH(
      0,
      0,
      MediaQuery.of(context).size.width - kSidePanelWidth,
      MediaQuery.of(context).size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    late final PlaygroundModel model = context.watch<PlaygroundModel>();
    final Color handleColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GridPaper(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? kGridColor.withOpacity(0.1)
                        : kGridColor,
                  ),
                ),
                if (model.clampingEnabled && playgroundArea != null)
                  ResizableBox(
                    box: model.clampingBox,
                    flip: Flip.none,
                    clampingBox: playgroundArea!,
                    onChanged: (rect, flip) {
                      model.setClampingBox(rect);
                    },
                    handleGestureResponseDiameter: 32,
                    handleBuilder: (context, handle) =>
                        const ColoredBox(color: Colors.red),
                    contentBuilder: (context, _, flip) => Container(
                      width: model.clampingBox.width,
                      height: model.clampingBox.height,
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Clamping Box',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ResizableBox(
                  box: model.box,
                  flip: model.flip,
                  clampingBox: model.clampingEnabled ? model.clampingBox : null,
                  onChanged: model.onRectChanged,
                  contentBuilder: (context, rect, flip) => Transform.scale(
                    scaleX: model.flipEnabled && flip.isHorizontal ? -1 : 1,
                    scaleY: model.flipEnabled && flip.isVertical ? -1 : 1,
                    child: Container(
                      width: rect.width,
                      height: rect.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/landscape2.jpg'),
                          fit: BoxFit.fill,
                        ),
                        border: Border.all(
                          color: handleColor,
                          width: 2,
                        ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.1),
                        //     blurRadius: 8,
                        //     spreadRadius: 5,
                        //   ),
                        // ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const ControlPanel(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaygroundModel model = context.watch<PlaygroundModel>();
    return Card(
      margin: const EdgeInsets.only(left: 0),
      shape: const RoundedRectangleBorder(),
      child: SizedBox(
        width: kSidePanelWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => model.reset(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    tooltip: 'Open on GitHub',
                    onPressed: () => launchUrlString(
                        'https://github.com/birjuvachhani/rect_resizer'),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        AdaptiveTheme.of(context).toggleThemeMode(),
                    tooltip: 'Toggle Theme',
                    icon: ValueListenableBuilder<AdaptiveThemeMode>(
                      valueListenable:
                          AdaptiveTheme.of(context).modeChangeNotifier,
                      builder: (context, mode, child) => Icon(
                        mode == AdaptiveThemeMode.system
                            ? Icons.brightness_auto_outlined
                            : mode == AdaptiveThemeMode.dark
                                ? Icons.brightness_2_outlined
                                : Icons.brightness_5_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const PositionControls(),
            const Divider(height: 1),
            const FlipControls(),
            const Divider(height: 1),
            const ClampingControls(),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class PositionControls extends StatelessWidget {
  const PositionControls({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaygroundModel model = context.watch<PlaygroundModel>();
    final Rect rect = model.box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader('POSITION'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Expanded(child: Label('X')),
                  SizedBox(width: 16),
                  Expanded(child: Label('Y')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ValueText(rect.left.toStringAsFixed(0)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ValueText(rect.top.toStringAsFixed(0)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Label('WIDTH')),
                  SizedBox(width: 16),
                  Expanded(child: Label('HEIGHT')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ValueText(rect.width.toStringAsFixed(0)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ValueText(rect.height.toStringAsFixed(0)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(child: Label('ASPECT RATIO')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ValueText(
                      (rect.width / rect.height).toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlipControls extends StatelessWidget {
  const FlipControls({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaygroundModel model = context.watch<PlaygroundModel>();
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            height: 44,
            padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'FLIP',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: model.flipEnabled,
                      onChanged: (value) => model.onFlipEnabledChanged(value),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (model.flipEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  ToggleButtons(
                    onPressed: (index) {
                      if (index == 0) {
                        model.flipHorizontally();
                      } else {
                        model.flipVertically();
                      }
                    },
                    isSelected: [
                      model.flip.isHorizontal,
                      model.flip.isVertical,
                    ],
                    selectedColor: Theme.of(context).colorScheme.primary,
                    constraints: const BoxConstraints.tightFor(height: 32),
                    children: [
                      Tooltip(
                        message: 'Flip Horizontally',
                        waitDuration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: const [
                              ImageIcon(
                                AssetImage('assets/images/ic_flip.png'),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('Horizontal'),
                            ],
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Flip Vertically',
                        waitDuration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: const [
                              RotatedBox(
                                quarterTurns: 1,
                                child: ImageIcon(
                                  AssetImage('assets/images/ic_flip.png'),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Vertical'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ClampingControls extends StatefulWidget {
  const ClampingControls({super.key});

  @override
  State<ClampingControls> createState() => _ClampingControlsState();
}

class _ClampingControlsState extends State<ClampingControls> {
  late final PlaygroundModel model = context.read<PlaygroundModel>();

  late final TextEditingController leftController;
  late final TextEditingController topController;
  late final TextEditingController bottomController;
  late final TextEditingController rightController;

  double get left => double.tryParse(leftController.text) ?? 0;

  double get top => double.tryParse(topController.text) ?? 0;

  double get bottom => double.tryParse(bottomController.text) ?? 0;

  double get right => double.tryParse(rightController.text) ?? 0;

  @override
  void initState() {
    super.initState();
    leftController =
        TextEditingController(text: model.clampingBox.left.toStringAsFixed(0));
    topController =
        TextEditingController(text: model.clampingBox.top.toStringAsFixed(0));
    bottomController = TextEditingController(
        text: model.clampingBox.bottom.toStringAsFixed(0));
    rightController =
        TextEditingController(text: model.clampingBox.right.toStringAsFixed(0));

    model.addListener(onModelChanged);
  }

  void onModelChanged() {
    if (model.clampingBox.left != left) {
      leftController.text = model.clampingBox.left.toStringAsFixed(0);
    }
    if (model.clampingBox.top != top) {
      topController.text = model.clampingBox.top.toStringAsFixed(0);
    }
    if (model.clampingBox.bottom != bottom) {
      bottomController.text = model.clampingBox.bottom.toStringAsFixed(0);
    }
    if (model.clampingBox.right != right) {
      rightController.text = model.clampingBox.right.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlaygroundModel model = context.watch<PlaygroundModel>();
    return FocusScope(
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              model.onClampingBoxChanged(
                left: left,
                top: top,
                bottom: bottom,
                right: right,
              );
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // color: Theme.of(context)
                    //     .colorScheme
                    //     .secondary
                    //     .withOpacity(0.1),
                    height: 44,
                    padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'CLAMPING',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: Transform.scale(
                            scale: 0.7,
                            child: Switch(
                              value: model.clampingEnabled,
                              onChanged: (value) =>
                                  model.onClampingEnabledChanged(value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (model.clampingEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: const [
                              Expanded(child: Label('LEFT')),
                              SizedBox(width: 16),
                              Expanded(child: Label('TOP')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  enabled: model.clampingEnabled,
                                  controller: leftController,
                                  onSubmitted: (value) {
                                    model.onClampingBoxChanged(left: left);
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: 'px',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]*'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  enabled: model.clampingEnabled,
                                  controller: topController,
                                  onSubmitted: (value) {
                                    model.onClampingBoxChanged(top: top);
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: 'px',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]*'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Expanded(child: Label('RIGHT')),
                              SizedBox(width: 16),
                              Expanded(child: Label('BOTTOM')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  enabled: model.clampingEnabled,
                                  controller: rightController,
                                  onFieldSubmitted: (value) {
                                    model.onClampingBoxChanged(right: right);
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: 'px',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]*'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  enabled: model.clampingEnabled,
                                  controller: bottomController,
                                  onSubmitted: (value) {
                                    model.onClampingBoxChanged(bottom: bottom);
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: 'px',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]*'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              model.setClampingBox(
                                Rect.fromLTRB(
                                  0,
                                  0,
                                  MediaQuery.of(context).size.width -
                                      kSidePanelWidth,
                                  MediaQuery.of(context).size.height,
                                ),
                              );
                            },
                            icon: const Icon(Icons.fullscreen_rounded),
                            label: const Text('Full screen'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    model.removeListener(onModelChanged);
    super.dispose();
  }
}

class KeyboardListenerIndicator extends StatelessWidget {
  final List<String> pressedKeys;
  final VoidCallback onClear;

  const KeyboardListenerIndicator({
    super.key,
    required this.pressedKeys,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final key in pressedKeys)
          Container(
            margin: EdgeInsets.only(right: pressedKeys.last != key ? 12 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(1, 3),
                ),
              ],
            ),
            child: Text(
              key,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (pressedKeys.isNotEmpty)
          IconButton(
            onPressed: onClear,
            splashRadius: 16,
            iconSize: 18,
            icon: Icon(
              Icons.clear,
              color: Colors.grey.shade400,
            ),
          ),
      ],
    );
  }
}

class Label extends StatelessWidget {
  final String label;

  const Label(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class ValueText extends StatelessWidget {
  final String value;

  const ValueText(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}
