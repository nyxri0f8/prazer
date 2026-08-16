import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/prazer_colors.dart';
import '../constants/api_constants.dart';

/// Mandatory legal disclaimer component per design rules
class DisclaimerBanner extends StatelessWidget {
  final bool isCompact;

  const DisclaimerBanner({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: PrazerColors.alabasterGrey.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PrazerColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: PrazerColors.blueSlate,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ApiConstants.legalDisclaimer,
              style: GoogleFonts.montserrat(
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w400,
                color: PrazerColors.blueSlate,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
