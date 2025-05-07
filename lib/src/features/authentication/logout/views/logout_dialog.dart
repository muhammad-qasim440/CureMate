










// onPressed: () async {
//   final isNetworkAvailable = ref.read(
//     checkInternetConnectionProvider,
//   );
//   final isConnected =
//       await isNetworkAvailable
//           .whenData((value) => value)
//           .value ??
//           false;
//
//   if (!isConnected) {
//     CustomSnackBarWidget.show(
//       context: context,
//       backgroundColor: AppColors.gradientGreen,
//       text: "No Internet Connection",
//     );
//     return;
//   }
//   try {
//
//     await ref
//         .read(authProvider)
//         .logout(
//       context,
//     );
//   } catch (e) {
//     CustomSnackBarWidget.show(
//       context: context,
//       text: "$e",
//     );
//   }
// }
