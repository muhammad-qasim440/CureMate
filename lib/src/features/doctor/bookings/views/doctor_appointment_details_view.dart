import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../router/nav.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/back_view_icon_widget.dart';
import '../../../bookings/models/appointment_model.dart';
import 'patient_details_view.dart';

class DoctorAppointmentDetailsView extends ConsumerWidget {
  final AppointmentModel appointment;
  final Patient patient;

  const DoctorAppointmentDetailsView({
    super.key,
    required this.appointment,
    required this.patient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool canComplete = false;
    if (appointment.status == 'accepted') {
      try {
        final dateFormat = DateFormat('yyyy-MM-dd');
        final timeFormat = DateFormat('hh:mm a');
        final appointmentDate = dateFormat.parse(appointment.date);
        final appointmentTime = timeFormat.parse(appointment.timeSlot);
        final appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          appointmentTime.hour,
          appointmentTime.minute,
        );
        final now = DateTime.now();
        final difference = now.difference(appointmentDateTime);
        canComplete = difference.inMinutes >= 30;
      } catch (e) {
        debugPrint('Error parsing date/time: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading:const BackViewIconWidget() ,
        titleSpacing: 0,
        leadingWidth: 60,
        title: Text(
          'Appointment Details',
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.gradientGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientSection(context),
            _buildAppointmentDetails(context),
            if (appointment.patientNotes != null && appointment.patientNotes!.isNotEmpty)
              _buildNotesSection(context),
            if (appointment.status == 'pending')
              _buildPendingActions(context, ref)
            else if (appointment.status == 'accepted' && canComplete)
              _buildCompleteAction(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigation.push(PatientDetailsView(patient: patient));
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: patient.profileImageUrl.isNotEmpty
                  ? NetworkImage(patient.profileImageUrl)
                  : null,
              child: patient.profileImageUrl.isEmpty
                  ? Text(
                      patient.fullName[0],
                      style: TextStyle(
                        fontSize: FontSizes(context).size24,
                        fontFamily: AppFonts.rubik,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: TextStyle(
                      fontSize: FontSizes(context).size18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.rubik,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view patient details',
                    style: TextStyle(
                      fontSize: FontSizes(context).size14,
                      color: Colors.grey.shade600,
                      fontFamily: AppFonts.rubik,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Information',
            style: TextStyle(
              fontSize: FontSizes(context).size18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.rubik,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Date', appointment.date),
          _buildInfoRow(context, 'Time', appointment.timeSlot),
          _buildInfoRow(context, 'Status', appointment.status.toUpperCase()),
          _buildInfoRow(context, 'Created At', appointment.createdAt.formattedDate),
          if (appointment.patientType != 'My Self') ...[
            _buildInfoRow(context, 'Patient Name', appointment.patientName),
            _buildInfoRow(context, 'Relation', appointment.patientType),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Notes',
            style: TextStyle(
              fontSize: FontSizes(context).size18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.rubik,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appointment.patientNotes!,
            style: TextStyle(
              fontSize: FontSizes(context).size16,
              color: Colors.black87,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                color: Colors.grey.shade600,
                fontFamily: AppFonts.rubik,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                color: label == 'Status' ? _getStatusColor(value.toLowerCase()) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CustomButtonWidget(
              text: 'Accept',
              height: ScreenUtil.scaleHeight(context, 50),
              backgroundColor: AppColors.gradientGreen,
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size16,
              fontWeight: FontWeight.w500,
              textColor: Colors.white,
              onPressed: () => _updateAppointmentStatus(context, ref, 'accepted'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButtonWidget(
              text: 'Reject',
              height: ScreenUtil.scaleHeight(context, 50),
              backgroundColor: Colors.white,
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size16,
              fontWeight: FontWeight.w500,
              textColor: Colors.red,
              border: const BorderSide(color: Colors.red),
              onPressed: () => _updateAppointmentStatus(context, ref, 'rejected'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteAction(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomButtonWidget(
        text: 'Complete Appointment',
        height: ScreenUtil.scaleHeight(context, 50),
        backgroundColor: Colors.blue,
        fontFamily: AppFonts.rubik,
        fontSize: FontSizes(context).size16,
        fontWeight: FontWeight.w500,
        textColor: Colors.white,
        onPressed: () => _updateAppointmentStatus(context, ref, 'completed'),
      ),
    );
  }

  Future<void> _updateAppointmentStatus(BuildContext context, WidgetRef ref, String status) async {
    final isConnected = await ref.read(checkInternetConnectionProvider.future);
    if (!isConnected) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No Internet Connection',
      );
      return;
    }

    try {
      final database = FirebaseDatabase.instance.ref();
      await database.child('Appointments').child(appointment.id).update({
        'status': status,
      });

      if (context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Appointment ${status.toLowerCase()} successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to update appointment status: $e',
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.gradientGreen;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.black87;
    }
  }
} 