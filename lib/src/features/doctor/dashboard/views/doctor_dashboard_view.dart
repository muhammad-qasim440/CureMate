import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/src/features/doctor/doctor_main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../bookings/providers/booking_providers.dart';
import '../../../bookings/models/appointment_model.dart';
import '../../../../utils/screen_utils.dart';
import '../../../doctor/providers/doctor_providers.dart';
import '../../../patient/providers/patient_providers.dart';

class DoctorDashboardView extends ConsumerWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final doctorAsync = ref.watch(currentSignInDoctorDataProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.gradientGreen,
        onRefresh: () async {
          ref.refresh(appointmentsProvider);
          ref.refresh(currentSignInDoctorDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, doctorAsync),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPerformanceMetrics(context),
                    const SizedBox(height: 20),
                    _buildAppointmentChart(context, appointmentsAsync),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AsyncValue<Doctor?> doctorAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gradientGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            doctorAsync.when(
              data: (doctor) => Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: doctor?.profileImageUrl != null && doctor!.profileImageUrl.isNotEmpty
                        ? NetworkImage(doctor.profileImageUrl)
                        : null,
                    child: doctor?.profileImageUrl == null || doctor!.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: AppColors.gradientGreen)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    doctor?.fullName ?? 'Doctor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes(context).size24,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor?.category ?? 'Specialist',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: FontSizes(context).size16,
                      fontFamily: AppFonts.rubik,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(color: Colors.white),
              error: (_, __) => const Text('Error loading profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          text: 'Appointment Statistics',
          textStyle: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Consumer(
          builder: (context, ref, child) {
            final appointmentsAsync = ref.watch(appointmentsProvider);
            
            return appointmentsAsync.when(
              data: (appointments) {
                final totalAppointments = appointments.length;
                final completedAppointments = appointments.where((apt) => apt.status == 'completed').length;
                final pendingAppointments = appointments.where((apt) => apt.status == 'pending').length;
                final cancelledAppointments = appointments.where((apt) => apt.status == 'cancelled').length;

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
                      _buildMetricRow(context, 'Total Appointments', '$totalAppointments', '📊'),
                      const Divider(),
                      _buildMetricRow(context, 'Completed', '$completedAppointments', '✓'),
                      const Divider(),
                      _buildMetricRow(context, 'Pending', '$pendingAppointments', '⏳'),
                      const Divider(),
                      _buildMetricRow(context, 'Cancelled', '$cancelledAppointments', '❌'),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context, String title, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
              color: Colors.grey[600],
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: FontSizes(context).size16,
                  fontFamily: AppFonts.rubik,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Text(icon),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentChart(BuildContext context, AsyncValue<List<AppointmentModel>> appointmentsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          text: 'Weekly Appointments',
          textStyle: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
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
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} appointments',
                          TextStyle(
                            color: AppColors.gradientGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: FontSizes(context).size12,
                                  fontFamily: AppFonts.rubik,
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
                        getTitlesWidget: (value, meta) {
                          if (value == value.roundToDouble()) {
                            return Text(
                              value.toInt().toString(),
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
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: AppColors.gradientGreen,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading chart data'),
          ),
        ),
      ],
    );
  }

  List<int> _processWeeklyAppointments(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return weekDays.map((date) {
      return appointments.where((apt) {
        final appointmentDate = apt.createdAt.toDateTime(pattern: 'dd-MM-yyyy');
        return DateFormat('yyyy-MM-dd').format(appointmentDate) ==
               DateFormat('yyyy-MM-dd').format(date);
      }).length;
    }).toList();
  }
} 