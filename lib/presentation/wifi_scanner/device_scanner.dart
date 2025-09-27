import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:flutter/material.dart';

class DeviceScannerDialog extends StatefulWidget {
  @override
  _DeviceScannerDialogState createState() => _DeviceScannerDialogState();
}

class _DeviceScannerDialogState extends State<DeviceScannerDialog> {
  final TextEditingController controller = TextEditingController();
  String? errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth > 500;
    final dialogWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.8;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: dialogWidth,
                maxWidth: dialogWidth,
                maxHeight: screenHeight * 0.9, // يحدد أقصى ارتفاع ممكن
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Device Number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ColorManager.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Device Number',
                          errorText: errorMessage,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Spacer(), // بيسمح للمحتوى يتمدد
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              final input = controller.text.trim();
                              final deviceNumber = int.tryParse(input);
                              if (deviceNumber == null ||
                                  deviceNumber < 1 ||
                                  deviceNumber > 255) {
                                setState(() {
                                  errorMessage =
                                      'Enter valid number between 1 : 255';
                                });
                                return;
                              }
                              Navigator.of(context).pop(deviceNumber);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DeviceScanner {
  static Future<int> scanDevices(BuildContext context) async {
    final int? selectedIp = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => DeviceScannerDialog(),
    );
    return selectedIp ?? 0;
  }
}
