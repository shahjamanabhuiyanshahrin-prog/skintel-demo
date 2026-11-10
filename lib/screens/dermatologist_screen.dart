import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _bg = Color(0xFFF5EFEC);
const Color _dark = Color(0xFF171717);

class Doctor {
  final String name;
  final String city;
  final String qualification;
  final String designation;
  final String chamber;
  final String address;
  final String visitingTime;
  final String phone;
  final int? newFee;
  final int? followUpFee;
  final String sourceUrl;

  const Doctor({
    required this.name,
    required this.city,
    required this.qualification,
    required this.designation,
    required this.chamber,
    required this.address,
    required this.visitingTime,
    required this.phone,
    required this.newFee,
    required this.followUpFee,
    required this.sourceUrl,
  });
}

const List<Doctor> _doctors = [
  // DHAKA
  Doctor(
    name: 'Dr. Monika Parvin',
    city: 'Dhaka',
    qualification: 'MBBS, DDV (Skin)',
    designation: 'Consultant, Dermatology & Venereology',
    chamber: 'Delta Health Care, Rampura',
    address: '381/A, DIT Road, West Rampura, Dhaka',
    visitingTime: 'Saturday, Monday & Wednesday: 6:00–7:30 PM',
    phone: '01755598365',
    newFee: 700,
    followUpFee: 600,
    sourceUrl:
        'https://healthindex.bd/en/doctor/monika-parvin-dermatologist',
  ),
  Doctor(
    name: 'Asst. Prof. Dr. Afsana Nahid',
    city: 'Dhaka',
    qualification: 'MBBS (DMC), DDV, FCPS (Dermatology & Venereology)',
    designation: 'Associate Professor, Dhaka Medical College Hospital',
    chamber: 'Ibn Sina Diagnostic Center, Lalbagh',
    address: 'Room 403, 27/4 Dhakeshwori Road, Lalbagh, Dhaka',
    visitingTime: 'Saturday–Thursday: 7:30–9:30 PM',
    phone: '01783356048',
    newFee: 800,
    followUpFee: null,
    sourceUrl:
        'https://healthindex.bd/en/doctor/afsana-nahid-dermatologist',
  ),
  Doctor(
    name: 'Dr. Md. Mir Hassan',
    city: 'Dhaka',
    qualification: 'MBBS (Dhaka), DDV (BSMMU)',
    designation: 'Assistant Professor, Dermatology',
    chamber: 'Medinet Medical Services, Mirpur',
    address: 'Plots 1, 2, 3, BNSB Building, Kalwalapara, Mirpur-1, Dhaka',
    visitingTime: 'Saturday & Thursday: 7:00–9:00 PM',
    phone: '',
    newFee: 700,
    followUpFee: 700,
    sourceUrl:
        'https://healthindex.bd/en/doctor/md-mir-hassan-dermatologist',
  ),

  // SYLHET
  Doctor(
    name: 'Dr. Arif Uddin Ahmed',
    city: 'Sylhet',
    qualification: 'MBBS, DDV',
    designation: 'Associate Professor, Dermatology & Venereology',
    chamber: 'North East Medical College Hospital',
    address: 'Basement B-6, South Surma, Sylhet',
    visitingTime: 'Sunday–Thursday: 10:00 AM–1:30 PM',
    phone: '01715944733',
    newFee: 400,
    followUpFee: null,
    sourceUrl:
        'https://healthindex.bd/en/doctor/arif-uddin-ahmed-dermatologist-sylhet',
  ),
  Doctor(
    name: 'Dr. Dhrubajyoti Roy Chowdhury',
    city: 'Sylhet',
    qualification: 'MBBS, DDV, FCPS (Skin & Sex)',
    designation: 'Dermatology & Cosmetic Surgeon',
    chamber: 'Trust Medical Services',
    address: '16, Modhushahid, Osmani Medical Road, Sylhet',
    visitingTime: 'Saturday–Thursday: 5:00–8:00 PM',
    phone: '01878785092',
    newFee: 800,
    followUpFee: 800,
    sourceUrl:
        'https://healthindex.bd/en/doctor/dhuvrojyoti-roy-chowdhury-dermatologist',
  ),
  Doctor(
    name: 'Dr. Md. Mahbubur Rahman',
    city: 'Sylhet',
    qualification: 'MBBS, BCS (Health), DDV (BSMMU)',
    designation: 'Dermatologist, Skin & Allergy Specialist',
    chamber: 'Medicare Medical Services',
    address: 'Azadi 115, Mirboxtula, Sylhet',
    visitingTime: '6:00–8:00 PM (Friday closed)',
    phone: '01725448600',
    newFee: 700,
    followUpFee: 500,
    sourceUrl:
        'https://docbd.org/doctor/dr-md-mahbubur-rahman-2',
  ),
  Doctor(
    name: 'Dr. Md. Zakaria',
    city: 'Sylhet',
    qualification: 'MBBS, MCPS, DDV',
    designation: 'Dermatologist & Venereologist',
    chamber: 'Ibn Sina Diagnostic & Consultation Center',
    address: 'Room 404, New Medical College Road, Rikabi Bazar, Sylhet',
    visitingTime: 'Saturday–Thursday: 6:00–10:00 PM',
    phone: '01601993028',
    newFee: null,
    followUpFee: null,
    sourceUrl: 'https://drmdzakaria.com/contact/',
  ),
];

class DermatologistScreen extends StatefulWidget {
  const DermatologistScreen({super.key});

  @override
  State<DermatologistScreen> createState() =>
      _DermatologistScreenState();
}

class _DermatologistScreenState extends State<DermatologistScreen> {
  String selectedCity = 'All';
  String searchText = '';

  List<Doctor> get filteredDoctors {
    return _doctors.where((doctor) {
      final cityMatches =
          selectedCity == 'All' || doctor.city == selectedCity;

      final query = searchText.toLowerCase();

      final searchMatches =
          doctor.name.toLowerCase().contains(query) ||
          doctor.chamber.toLowerCase().contains(query) ||
          doctor.qualification.toLowerCase().contains(query) ||
          doctor.designation.toLowerCase().contains(query);

      return cityMatches && searchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = filteredDoctors;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Find a Dermatologist',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() => searchText = value);
              },
              decoration: InputDecoration(
                hintText: 'Search doctor, chamber or qualification',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: ['All', 'Dhaka', 'Sylhet'].map((city) {
                final selected = selectedCity == city;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(
                          city,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: selected,
                      selectedColor: _dark,
                      backgroundColor: _bg,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : _dark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => selectedCity = city);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${doctors.length} dermatologist${doctors.length == 1 ? '' : 's'} found',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          Expanded(
            child: doctors.isEmpty
                ? const Center(
                    child: Text('No dermatologist found.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _doctorCard(doctors[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _doctorCard(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6DAD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.brown.shade300,
                child: Text(
                  doctor.name
                      .replaceAll('Dr. ', '')
                      .replaceAll('Asst. Prof. ', '')[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.designation,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.city,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.brown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 22),

          _infoRow(Icons.local_hospital_outlined, doctor.chamber),
          const SizedBox(height: 7),
          _infoRow(Icons.location_on_outlined, doctor.address),
          const SizedBox(height: 7),
          _infoRow(Icons.access_time, doctor.visitingTime),
          const SizedBox(height: 7),
          _infoRow(
            Icons.payments_outlined,
            doctor.newFee == null
                ? 'Consultation fee: Call to confirm'
                : 'New visit: ৳${doctor.newFee}'
                    '${doctor.followUpFee == null ? '' : '  •  Follow-up: ৳${doctor.followUpFee}'}',
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDetails(doctor),
                  icon: const Icon(Icons.info_outline, size: 17),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _dark,
                    side: const BorderSide(color: _dark),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: doctor.phone.isEmpty
                      ? null
                      : () => _callDoctor(doctor.phone),
                  icon: const Icon(Icons.call, size: 17),
                  label: const Text('Call for serial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.brown),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),
        ),
      ],
    );
  }

  void _showDetails(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }

  Future<void> _callDoctor(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);

    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone app.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone app.')),
      );
    }
  }
}

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
  });

  Future<void> _openSource(BuildContext context) async {
    final uri = Uri.parse(doctor.sourceUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open source link.')),
      );
    }
  }

  Future<void> _call(BuildContext context) async {
    if (doctor.phone.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: doctor.phone);

    try {
      await launchUrl(uri);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.brown.shade300,
            child: Text(
              doctor.name[0],
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            doctor.designation,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _detail('City', doctor.city),
          _detail('Qualification', doctor.qualification),
          _detail('Chamber', doctor.chamber),
          _detail('Address', doctor.address),
          _detail('Visiting hours', doctor.visitingTime),
          _detail(
            'New patient fee',
            doctor.newFee == null ? 'Call to confirm' : '৳${doctor.newFee}',
          ),
          _detail(
            'Follow-up fee',
            doctor.followUpFee == null
                ? 'Not published / call to confirm'
                : '৳${doctor.followUpFee}',
          ),
          _detail(
            'Appointment number',
            doctor.phone.isEmpty ? 'Not available in source' : doctor.phone,
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: doctor.phone.isEmpty ? null : () => _call(context),
            icon: const Icon(Icons.call),
            label: const Text('Call for appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: () => _openSource(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('View information source'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _dark,
              padding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Please call the chamber before visiting to confirm '
            'the latest consultation fee, schedule and appointment availability. '
            'Doctor information is collected from public directory listings '
            'and is not a live hospital confirmation.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}