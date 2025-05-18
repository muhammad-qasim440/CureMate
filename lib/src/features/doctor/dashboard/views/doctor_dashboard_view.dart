import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/models/appointment_model.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../doctor/providers/doctor_providers.dart';
import '../../../patient/providers/patient_providers.dart';
import '../widgets/doctor_reviews_widget.dart';

class DoctorDashboardView extends ConsumerWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final doctorAsync = ref.watch(currentSignInDoctorDataProvider);

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          RefreshIndicator(
            color: AppColors.gradientGreen,
            onRefresh: () async {
              ref.refresh(appointmentsProvider);
              ref.refresh(currentSignInDoctorDataProvider);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, doctorAsync),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDoctorStats(context),
                          const SizedBox(height: 20),
                          _buildAppointmentStats(context),
                          const SizedBox(height: 20),
                          _buildStatsChart(context),
                          const SizedBox(height: 20),
                          _buildAppointmentChart(context, appointmentsAsync),
                          const SizedBox(height: 20),
                          const DoctorReviewsWidget(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AsyncValue<Doctor?> doctorAsync,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientGreen,
            AppColors.gradientGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            doctorAsync.when(
              data:
                  (doctor) => Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      doctor?.profileImageUrl != null &&
                                              doctor!.profileImageUrl.isNotEmpty
                                          ? NetworkImage(doctor.profileImageUrl)
                                          : null,
                                  child:
                                      doctor?.profileImageUrl == null ||
                                              doctor!.profileImageUrl.isEmpty
                                          ? const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.gradientGreen,
                                          )
                                          : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doctor!.averageRatings.toStringAsFixed(
                                          1,
                                        ),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: FontSizes(context).size14,
                                          fontFamily: AppFonts.rubik,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.fullName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSizes(context).size20,
                                    fontFamily: AppFonts.rubik,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    doctor.category,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: FontSizes(context).size14,
                                      fontFamily: AppFonts.rubik,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              loading:
                  () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => const Text('Error loading profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorStats(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final doctorAsync = ref.watch(currentSignInDoctorDataProvider);

        return doctorAsync.when(
          data: (doctor) {
            if (doctor == null) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'Total Patients',
                    '${doctor.totalPatientConsulted}',
                    Icons.people_outline,
                    Colors.blue,
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    context,
                    'Profile Views',
                    '${doctor.profileViews}',
                    Icons.remove_red_eye_outlined,
                    Colors.purple,
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    context,
                    'Experience',
                    '${doctor.yearsOfExperience} Yrs',
                    Icons.work_outline,
                    Colors.orange,
                  ),
                ],
              ),
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.gradientGreen,
                  ),
                ),
              ),
          error:
              (error, stack) => Center(
                child: Text(
                  'Error loading stats',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: FontSizes(context).size14,
                    fontFamily: AppFonts.rubik,
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: FontSizes(context).size12,
            fontFamily: AppFonts.rubik,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  Widget _buildAppointmentStats(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final appointmentsAsync = ref.watch(appointmentsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: 'Appointment Statistics',
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size18,
                    fontFamily: AppFonts.rubik,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gradientGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: AppColors.gradientGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: AppColors.gradientGreen,
                          fontSize: FontSizes(context).size12,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            appointmentsAsync.when(
              data: (appointments) {
                final totalAppointments = appointments.length;
                final completedAppointments =
                    appointments
                        .where((apt) => apt.status == 'completed')
                        .length;
                final pendingAppointments =
                    appointments.where((apt) => apt.status == 'pending').length;
                final acceptedAppointments =
                    appointments
                        .where((apt) => apt.status == 'accepted')
                        .length;
                final cancelledAppointments =
                    appointments
                        .where((apt) => apt.status == 'cancelled')
                        .length;

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow(
                        context,
                        'Total Appointments',
                        '$totalAppointments',
                        Icons.calendar_month_outlined,
                        AppColors.gradientGreen,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        'Completed',
                        '$completedAppointments',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        'Accepted',
                        '$acceptedAppointments',
                        Icons.thumb_up_outlined,
                        Colors.blue,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        'Pending',
                        '$pendingAppointments',
                        Icons.pending_outlined,
                        Colors.orange,
                      ),
                      const Divider(),
                      _buildMetricRow(
                        context,
                        'Cancelled',
                        '$cancelledAppointments',
                        Icons.cancel_outlined,
                        Colors.red,
                      ),
                    ],
                  ),
                );
              },
              loading:
                  () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.gradientGreen,
                      ),
                    ),
                  ),
              error:
                  (error, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Error loading statistics',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: FontSizes(context).size14,
                            fontFamily: AppFonts.rubik,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: FontSizes(context).size14,
                  fontFamily: AppFonts.rubik,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsChart(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final doctorAsync = ref.watch(currentSignInDoctorDataProvider);

        return doctorAsync.when(
          data: (doctor) {
            if (doctor == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: 'Profile Views',
                      textStyle: TextStyle(
                        fontSize: FontSizes(context).size18,
                        fontFamily: AppFonts.rubik,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gradientGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: AppColors.gradientGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Total: ${doctor.profileViews}',
                            style: TextStyle(
                              color: AppColors.gradientGreen,
                              fontSize: FontSizes(context).size12,
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      doctor.profileViews == 0
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No profile views yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: FontSizes(context).size14,
                                    fontFamily: AppFonts.rubik,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: _calculateChartInterval(
                                  doctor.profileViews,
                                ),
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[200],
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) {
                                        return Text(
                                          'Start',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: FontSizes(context).size12,
                                            fontFamily: AppFonts.rubik,
                                          ),
                                        );
                                      } else if (value == 1) {
                                        return Text(
                                          'Current',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: FontSizes(context).size12,
                                            fontFamily: AppFonts.rubik,
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: _calculateChartInterval(
                                      doctor.profileViews,
                                    ),
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: FontSizes(context).size12,
                                          fontFamily: AppFonts.rubik,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              minX: 0,
                              maxX: 1,
                              minY: 0,
                              maxY:
                                  (doctor.profileViews +
                                          _calculateChartInterval(
                                            doctor.profileViews,
                                          ))
                                      .toDouble(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 0),
                                    FlSpot(1, doctor.profileViews.toDouble()),
                                  ],
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.gradientGreen.withOpacity(0.7),
                                      AppColors.gradientGreen,
                                    ],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.gradientGreen.withOpacity(
                                          0.2,
                                        ),
                                        AppColors.gradientGreen.withOpacity(
                                          0.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.gradientGreen,
                  ),
                ),
              ),
          error: (_, __) => const Text('Error loading chart'),
        );
      },
    );
  }

  Widget _buildAppointmentChart(
    BuildContext context,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              text: 'Weekly Appointments',
              textStyle: TextStyle(
                fontSize: FontSizes(context).size18,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gradientGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.gradientGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'This Week',
                    style: TextStyle(
                      color: AppColors.gradientGreen,
                      fontSize: FontSizes(context).size12,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: appointmentsAsync.when(
            data: (appointments) {
              final weeklyData = _processWeeklyAppointments(appointments);
              final maxY =
                  weeklyData.reduce((a, b) => a > b ? a : b).toDouble();
              final interval = _calculateChartInterval(maxY.toInt());

              if (weeklyData.every((count) => count == 0)) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments this week',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: FontSizes(context).size14,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxY + interval).ceilToDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide(
                        color: AppColors.gradientGreen.withOpacity(0.1),
                        width: 1,
                      ),
                      tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} appointments',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                          ),
                        );
                      },
                      getTooltipColor:
                          (group) => AppColors.gradientGreen.withOpacity(0.8),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      direction: TooltipDirection.top,
                      rotateAngle: 0,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: FontSizes(context).size12,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: FontSizes(context).size12,
                              fontFamily: AppFonts.rubik,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[200], strokeWidth: 1);
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  barGroups:
                      weeklyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.gradientGreen.withOpacity(0.7),
                                  AppColors.gradientGreen,
                                ],
                              ),
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.gradientGreen,
                    ),
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading appointments',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: FontSizes(context).size14,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  List<int> _processWeeklyAppointments(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    final weeklyData =
        weekDays.map((date) {
          return appointments.where((apt) {
            try {
              final appointmentDate = DateTime.parse(apt.createdAt);
              return DateFormat('yyyy-MM-dd').format(appointmentDate) ==
                  DateFormat('yyyy-MM-dd').format(date);
            } catch (e) {
              logDebug('Error parsing date: ${apt.createdAt}');
              return false;
            }
          }).length;
        }).toList();

    // Calculate appropriate maxY based on data
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    final interval = _calculateChartInterval(maxValue);

    return weeklyData;
  }

  double _calculateChartInterval(int maxValue) {
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    return (maxValue / 5).ceil().toDouble();
  }
}
