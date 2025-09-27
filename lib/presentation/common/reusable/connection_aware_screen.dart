// import 'package:tranex_users/presentation/common/reusable/no_internet_connection_screen.dart';
// import 'package:tranex_users/presentation/common/reusable/toast.dart';
// import 'package:tranex_users/presentation/resources/color_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
//
// class ConnectionAwareScreen extends StatefulWidget {
//   final Widget child;
//
//   const ConnectionAwareScreen({super.key, required this.child});
//
//   @override
//   State<ConnectionAwareScreen> createState() => _ConnectionAwareScreenState();
// }
//
// class _ConnectionAwareScreenState extends State<ConnectionAwareScreen> {
//   bool _wasConnected = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<InternetStatus>(
//       stream: InternetConnection().onStatusChange,
//       builder: (context, snapshot) {
//         final isConnected =
//             snapshot.data == InternetStatus.connected || snapshot.data == null;
//
//         if (isConnected != _wasConnected) {
//           _wasConnected = isConnected;
//
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!mounted) return;
//             // isConnected
//             //     ? Toast.show("Internet Connection Available",
//             //         backgroundColor: ColorManager.green)
//             //     : Toast.show("No Internet Connection",
//             //         backgroundColor: ColorManager.red);
//           });
//         }
//
//         return isConnected
//             ? widget.child
//             : NoInternetScreen(
//                 onRetry: () async {
//                   final connected =
//                       await InternetConnection().hasInternetAccess;
//                   if (connected) {
//                     setState(() {}); // rebuild
//                   }
//                 },
//               );
//       },
//     );
//   }
// }
