import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_uikit/controllers/rtc_buttons.dart';
import 'package:agora_uikit/src/buttons/cloud_recording_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A UI class to style how the buttons look. Use this class to add, remove or customize the buttons in your live video calling application.
class AgoraVideoButtons extends StatefulWidget {
  final AgoraClient client;

  /// List of enabled buttons. Use this to remove any of the default button or change their order.
  final List<BuiltInButtons>? enabledButtons;

  /// List of buttons that are added next to the default buttons. The buttons class contains a horizontal scroll view.
  final List<Widget>? extraButtons;

  /// Automatically hides the button class after a default time of 5 seconds if not set otherwise.
  final bool? autoHideButtons;

  /// The default auto hide time = 5 seconds
  final int autoHideButtonTime;

  /// Adds a vertical padding to the set of button
  final double? verticalButtonPadding;

  /// Alignment for the button class
  final Alignment buttonAlignment;

  /// Use this to style the disconnect button as per your liking while still keeping the default functionality.
  final Widget? disconnectButtonChild;

  /// Use this to style the mute mic button as per your liking while still keeping the default functionality.
  final Widget? muteButtonChild;

  /// Use this to style the switch camera button as per your liking while still keeping the default functionality.
  final Widget? switchCameraButtonChild;

  /// Use this to style the disabled video button as per your liking while still keeping the default functionality.
  final Widget? disableVideoButtonChild;

  final Widget? screenSharingButtonWidget;

  final Widget? cloudRecordingButtonWidget;

  /// Agora VideoUIKit takes care of leaving the channel and destroying the engine. But if you want to add any other functionality to the disconnect button, use this.
  final Function()? onDisconnect;

  /// Adds Screen Sharing button to the layout and let's user share their screen using the same. Currently only on Android and iOS. The deafult value is set to `false`. So, if you want to add screen sharing set [addScreenSharing] to `true`.
  ///
  /// Note: This feature is currently in beta
  final bool? addScreenSharing;

  final bool? cloudRecordingEnabled;

  const AgoraVideoButtons({
    Key? key,
    required this.client,
    this.enabledButtons,
    this.extraButtons,
    this.autoHideButtons,
    this.autoHideButtonTime = 5,
    this.verticalButtonPadding,
    this.buttonAlignment = Alignment.bottomCenter,
    this.disconnectButtonChild,
    this.muteButtonChild,
    this.switchCameraButtonChild,
    this.disableVideoButtonChild,
    this.screenSharingButtonWidget,
    this.cloudRecordingButtonWidget,
    this.onDisconnect,
    this.addScreenSharing = false,
    this.cloudRecordingEnabled = false,
  }) : super(key: key);

  @override
  State<AgoraVideoButtons> createState() => _AgoraVideoButtonsState();
}

class _AgoraVideoButtonsState extends State<AgoraVideoButtons> {
  List<Widget> buttonsEnabled = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: widget.autoHideButtonTime),
      () {
        if (mounted) {
          setState(() {
            toggleVisible(
              value: widget.client.sessionController.value,
            );
          });
        }
      },
    );

    Map buttonMap = <BuiltInButtons, Widget>{
      BuiltInButtons.toggleMic: _muteMicButton(),
      BuiltInButtons.callEnd: _disconnectCallButton(),
      BuiltInButtons.switchCamera: _switchCameraButton(),
      BuiltInButtons.toggleCamera: _disableVideoButton(),
    };

    if (widget.enabledButtons != null) {
      for (var i = 0; i < widget.enabledButtons!.length; i++) {
        for (var j = 0; j < buttonMap.length; j++) {
          if (buttonMap.keys.toList()[j] == widget.enabledButtons![i]) {
            buttonsEnabled.add(buttonMap.values.toList()[j]);
          }
        }
      }
    }
  }

  Widget toolbar(List<Widget>? buttonList) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 690,
            child: Container(
              width: 393,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(400, 200),
                ),
                color: Color.fromRGBO(221, 222, 252, 0.6),
              ),
            ),
          ),
          _muteMicButton(),
          _disconnectCallButton(),
          _disableVideoButton(),
        ],
      ),
    );
  }

  Widget _muteMicButton() {
    return Positioned(
      bottom: 36,
      left: 30,
      top: 675,
      child: Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Color(0XFFD2ACFF), Color(0XFFB2DDFD)]),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: widget.client.sessionController.value.isLocalUserMuted
                        ? FaIcon(FontAwesomeIcons.microphoneSlash)
                        : FaIcon(FontAwesomeIcons.microphone),
                    onPressed: () => toggleMute(
                      sessionController: widget.client.sessionController,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _disconnectCallButton() {
    return Positioned(
      bottom: 60,
      left: 160,
      child: Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: const Color.fromRGBO(230, 71, 71, 1.0)),
                  child: IconButton(
                      color: Colors.white,
                      icon: FaIcon(FontAwesomeIcons.phoneSlash),
                      onPressed: () => _onCallEnd(context)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _switchCameraButton() {
    return widget.switchCameraButtonChild != null
        ? RawMaterialButton(
            onPressed: () => switchCamera(
              sessionController: widget.client.sessionController,
            ),
            child: widget.switchCameraButtonChild,
          )
        : RawMaterialButton(
            onPressed: () => switchCamera(
              sessionController: widget.client.sessionController,
            ),
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          );
  }

  Widget _disableVideoButton() {
    return Positioned(
      bottom: 36,
      right: 30,
      top: 675,
      child: Row(
        children: [
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Color(0XFFD2ACFF), Color(0XFFB2DDFD)]),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: widget
                            .client.sessionController.value.isLocalVideoDisabled
                        ? FaIcon(FontAwesomeIcons.videoSlash)
                        : FaIcon(FontAwesomeIcons.video),
                    onPressed: () => toggleCamera(
                      sessionController: widget.client.sessionController,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Default functionality of disconnect button is such that it pops the view and navigates the user to the previous screen.
  Future<void> _onCallEnd(BuildContext context) async {
    if (widget.onDisconnect != null) {
      await widget.onDisconnect!();
    } else {
      Navigator.pop(context);
    }
    await widget.client.release();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.client.sessionController,
        builder: (context, counter, something) {
          return widget.autoHideButtons != null
              ? widget.autoHideButtons!
                  ? Visibility(
                      visible: widget.client.sessionController.value.visible,
                      child: toolbar(widget.enabledButtons == null
                          ? null
                          : buttonsEnabled),
                    )
                  : toolbar(
                      widget.enabledButtons == null ? null : buttonsEnabled)
              : toolbar(widget.enabledButtons == null ? null : buttonsEnabled);
        });
  }
}
