import 'package:flutter/material.dart';
import 'package:virtualfundi/database/database.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {

  // teacherInfo
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _classStreamController = TextEditingController();
  final TextEditingController _topicCoveredController = TextEditingController();
  final TextEditingController _sessionsCoveredController = TextEditingController();

  // tab usauge
  String _tabletUsage = 'Daily';
  String _tabletEaseOfUse = 'Very Easy';
  String _digitalContentUsefulnes = '1';
  String _prepTimeSaved = 'More Time Saved';
  String _effectivenessOfIntruc = 'Very Effective';


  // video content
  // Stores user ratings
  Map<String, int> _ratings = {
    "usefulness": 3,
    "explanation": 3,
    "experiments": 3,
    "flow": 3,
    "quality": 3,
  };
  String _escVideoHelpfulness = "Very Helpful";
  String _confidenceInESC = "1";
  String _escVideoPreparation = "Yes";

  // OverallEval
  int _satisfactionRating = 3;
  List<String> _challenges = [];
  final TextEditingController _improvementsController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teacherNameController.dispose();
    _schoolNameController.dispose();
    _classStreamController.dispose();
    _topicCoveredController.dispose();
    _sessionsCoveredController.dispose();
    _improvementsController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF6A0DAD),
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: "Teacher Info"),
            Tab(text: "Tablet Usage"),
            Tab(text: "Videos & Content"),
            Tab(text: "Overall Eval"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveWrapper(child: _buildTeacherInfoTab()),
          KeepAliveWrapper(child: _buildTabletUsageTab()),
          KeepAliveWrapper(child: _buildVideosContentTab()),
          KeepAliveWrapper(child: _buildOverallEvalTab()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleSubmit,
        label: Text("Submit"),
        icon: Icon(Icons.send),
        backgroundColor: Color(0xFF6A0DAD),
      ),
    );
  }

  Widget _buildTeacherInfoTab() {
    return _buildScrollableContent([
      _buildTextField("Name of the Teacher:", _teacherNameController),
      _buildTextField("School Name:", _schoolNameController),
      _buildTextField("Class and Stream:", _classStreamController),
      _buildTextField("Topic Covered:", _topicCoveredController),
      _buildTextField("Sessions covered:", _sessionsCoveredController),
    ]);
  }

  Widget _buildTabletUsageTab() {
    return _buildScrollableContent([
      _buildSectionHeader('How often do you use the Virtual Fundi tablet?'),
      _buildRadioGroup(['Daily', 'Weekly', 'Rarely', 'Never'], _tabletUsage,
              (value) => setState(() => _tabletUsage = value!)),

      _buildSectionHeader('How easy is it to use the tablet for lessons?'),
      _buildRadioGroup(
          ['Very Easy', 'Neutral', 'Somewhat Difficult', 'Very Difficult'],
          _tabletEaseOfUse,
              (value) => setState(() => _tabletEaseOfUse = value!)),

      _buildSectionHeader('How useful are the digital content and resources on the tablet for preparing your lessons?  1 for Not Useful & 5 for Very Useful'),
      _buildRadioGroup(
        ['1', '2', '3', '4', '5'],
        _digitalContentUsefulnes,
            (value) => setState(() => _tabletEaseOfUse = value!),
        // labels: ['Not Useful', 'Very Useful'],
      ),

      _buildSectionHeader('How much time do you save in lesson preparation by using the tablet compared to traditional methods?'),
      _buildRadioGroup(
        ['More Time Saved', 'Less Time Saved', 'About the Same Time', 'More Time Required'],
        _prepTimeSaved,
            (value) => setState(() => _tabletEaseOfUse = value!),
      ),

      _buildSectionHeader('How effective are the instructional guides in the Virtual Fundi assisting with lesson preparation?'),
      _buildRadioGroup(
        ['Very Effective', 'Effective', 'Neutral', 'Ineffective', 'Very Ineffective'],
        _effectivenessOfIntruc,
            (value) => setState(() => _tabletEaseOfUse = value!),
      ),

    ]);
  }


  Widget _buildVideosContentTab() {
    return _buildScrollableContent([
      _buildSectionHeader('Rate the content and videos based on the following criteria:'),

      _buildRatingMatrix({
        "Usefulness": "usefulness",
        "Explanation of concepts": "explanation",
        "Experiments covered": "experiments",
        "Flow of the content": "flow",
        "Quality of the videos": "quality",
      }),
      _buildSectionHeader('How helpful are the instructional videos in understanding the use of ESC tools?'),
      _buildRadioGroup(
        ['Very Helpful', 'Neutral', 'Not Helpful at All'],
        _escVideoHelpfulness,
            (value) => setState(() => _escVideoHelpfulness = value!),
      ),
      _buildSectionHeader('How confident do you feel using the Enhanced Science learning tools after watching the instructional videos?'),
      _buildRadioGroup(
        ['1', '2', '3', '4', '5'],
        _confidenceInESC,
            (value) => setState(() => _tabletEaseOfUse = value!),
        // labels: ['Not Useful', 'Very Useful'],
      ),

      _buildSectionHeader('Do you believe the videos adequately prepare teachers for effectively integrating the tools into lessons?'),
      _buildRadioGroup(
          ['Yes', 'No', 'Maybe'],
          _escVideoPreparation, // Define this variable similar to others
              (value) => setState(() => _escVideoPreparation = value!)),

    ]);
  }

  Widget _buildRatingMatrix(Map<String, String> criteria) {
    return Column(
      children: criteria.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(entry.key, style: TextStyle(fontSize: 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                return Column(
                  children: [
                    Text('${index + 1}', style: TextStyle(fontSize: 16)),
                    Radio<int>(
                      value: index + 1,
                      groupValue: _ratings[entry.value],
                      activeColor: Colors.purple,
                      onChanged: (newValue) {
                        setState(() => _ratings[entry.value] = newValue!);
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      }).toList(),
    );
  }


  Widget _buildOverallEvalTab() {
    return _buildScrollableContent([
      _buildSectionHeader("How satisfied are you with the Virtual Fundi tablet?"),
      _buildRatingRow(),

      _buildSectionHeader("Challenges faced while using the tablet:"),
      _buildCheckboxList([
        "Technical Issues",
        "Navigating the Interface",
        "Understanding Instructions",
        "Content aligning with Curriculum"
      ]),

      _buildSectionHeader("Improvements for the tablet and its content:"),
      _buildTextField("", _improvementsController),

      _buildSectionHeader("Any additional comments or suggestions?"),
      _buildTextField("", _commentsController),
    ]);
  }

  Widget _buildScrollableContent(List<Widget> children) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRadioGroup(List<String> options, String groupValue, ValueChanged<String?> onChanged) {
    return Column(
      children: options
          .map((option) => ListTile(
        leading: Radio<String>(
          value: option,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: Colors.purple,
        ),
        title: Text(option, style: TextStyle(fontSize: 16)),
      ))
          .toList(),
    );
  }

  Widget _buildCheckboxList(List<String> options) {
    return Column(
      children: options
          .map((option) => CheckboxListTile(
        title: Text(option),
        value: _challenges.contains(option),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _challenges.add(option);
            } else {
              _challenges.remove(option);
            }
          });
        },
        activeColor: Colors.purple,
      ))
          .toList(),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        return Column(
          children: [
            Text('${index + 1}', style: TextStyle(fontSize: 16)),
            Radio<int>(
              value: index + 1,
              groupValue: _satisfactionRating,
              activeColor: Colors.purple,
              onChanged: (newValue) => setState(() => _satisfactionRating = newValue!),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _handleSubmit() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase();

    final teacherData = TeacherData(
      teacherName: _teacherNameController.text.toString(),
      schoolName: _schoolNameController.text.toString(),
      classStream: _classStreamController.text.toString(),
      topicCovered: _topicCoveredController.text.toString(),
      sessionCovered: _sessionsCoveredController.text.toString(),

      // TabUsage Fields
      frequency: _tabletUsage,
      easeOfUse: _tabletEaseOfUse,
      digitalContentUsefulnes: _digitalContentUsefulnes,
      prepTimeSaved: _prepTimeSaved,
      effectivenessOfIntruc: _effectivenessOfIntruc,


      // VideoContent Fields
      // VideoContent Fields as a Key-Value Pair
      videoContentRatings: _ratings,
      escVideoHelpfulness: _escVideoHelpfulness,
      confidenceInESC: _confidenceInESC,
      escVideoPreparation: _escVideoPreparation,

      // Evaluation Fields
      overallSatisfaction: _satisfactionRating,
      challenges: _challenges,
      improvements: _improvementsController.text.toString(),
      additionalComments: _commentsController.text.toString(),
      evaluationDate: DateTime.now(),
    );

    //await insertTeacherData(teacherData);
    await dbHelper.insertTeacherData(teacherData);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Feedback submitted!')));
  }
}

/// **Fix for Disappearing Selections**
/// This keeps each tab’s state alive when switching.
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
