import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/resources/assets_manager.dart';
import 'package:tranex_users/presentation/resources/color_manager.dart';
import 'package:tranex_users/presentation/resources/font_manager.dart';
import 'package:tranex_users/presentation/resources/style_manager.dart';

class PlayerHeader extends StatelessWidget {
  final TraineeData traineeData;
  final int playerId;

  const PlayerHeader({
    super.key,
    this.playerId = 1,
    required this.traineeData,
  });
  String getCountryFlag(String countryCode) {
    if (countryCode.length != 2) return '';
    return String.fromCharCode(countryCode.codeUnitAt(0) + 127397) +
        String.fromCharCode(countryCode.codeUnitAt(1) + 127397);
  }

  @override
  Widget build(BuildContext context) {
    String playerName = traineeData.traineeName;
    String playerImage = traineeData.photo;
    String? countryCode = traineeData.country;
    String? weaponType = traineeData.weaponType;
    bool isActive = traineeData.isActive;
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    Color color = playerId == 1 ? Colors.blue : Colors.red;
    return Container(
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        border: Border.all(color: ColorManager.simiBlue),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: color,
            child: CircleAvatar(
              radius: 34.r,
              foregroundImage: playerImage.isNotEmpty
                  ? NetworkImage(playerImage)
                  : const AssetImage(ImageAssets.personal) as ImageProvider,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName.isNotEmpty
                      ? playerName[0].toUpperCase() + playerName.substring(1)
                      : 'Unknown',
                  style: getBoldStyle(
                      fontSize: isTablet ? FontSize.s25 : FontSize.s16,
                      color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                if (traineeData.isFencer)
                  Row(
                    children: [
                      if (countryCode != null)
                        Text(
                          getCountryFlag(countryCode),
                          style: getMediumStyle(
                              fontSize: isTablet ? FontSize.s25 : FontSize.s16,
                              color: color),
                        ),
                      SizedBox(width: 4.w),
                      if (weaponType != null)
                        Text(
                          weaponType,
                          style: getMediumStyle(
                              fontSize: isTablet ? FontSize.s25 : FontSize.s16,
                              color: Colors.grey[700]!),
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
