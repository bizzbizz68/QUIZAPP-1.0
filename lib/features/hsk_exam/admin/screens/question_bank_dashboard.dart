import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';
import '../../data/sources/hierarchical_question_bank_service.dart';
import '../../utils/hsk_structure.dart';
import 'add_edit_question_screen.dart';

/// Question Bank Dashboard - Ngân hàng câu hỏi HSK
class QuestionBankDashboard extends StatefulWidget {
  const QuestionBankDashboard({super.key});

  @override
  State<QuestionBankDashboard> createState() => _QuestionBankDashboardState();
}

class _QuestionBankDashboardState extends State<QuestionBankDashboard> {
  final _questionBankService = HierarchicalQuestionBankService();

  // Filters
  int? _selectedLevel;
  String? _selectedSection;
  QuestionType? _selectedType;
  bool _showInactiveOnly = false;

  List<QuestionModel> _questions = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('🔄 DEBUG: _loadData() called');
    print('🔍 DEBUG: Filters - Level: $_selectedLevel, Section: $_selectedSection, Type: $_selectedType');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<QuestionModel> questions = [];
      
      // Load questions based on filters
      if (_selectedLevel != null) {
        print('📍 DEBUG: Branch - Level selected: $_selectedLevel');
        if (_selectedType != null && _selectedSection != null) {
          print('📍 DEBUG: Branch - Getting by task type');
          // Get by task type
          questions = await _questionBankService.getQuestionsByTaskType(
            hskLevel: _selectedLevel!,
            section: _selectedSection!,
            questionType: _selectedType!,
          );
        } else if (_selectedSection != null) {
          print('📍 DEBUG: Branch - Getting by skill');
          // Get by skill
          questions = await _questionBankService.getQuestionsBySkill(
            hskLevel: _selectedLevel!,
            section: _selectedSection!,
          );
        } else {
          print('📍 DEBUG: Branch - Getting by level');
          // Get by level
          questions = await _questionBankService.getQuestionsByLevel(
            hskLevel: _selectedLevel!,
          );
        }
      } else {
        print('📍 DEBUG: Branch - No level selected, loading ALL levels (1-6)');
        // If no level selected, load from all levels
        for (int level = 1; level <= 6; level++) {
          print('📍 DEBUG: Loading level $level...');
          final levelQuestions = await _questionBankService.getQuestionsByLevel(
            hskLevel: level,
          );
          questions.addAll(levelQuestions);
        }
      }
      
      print('✅ DEBUG: Loaded ${questions.length} questions total');

      // TODO: isActive field not available in QuestionModel
      // Filter inactive if needed
      // if (_showInactiveOnly) {
      //   questions = questions.where((q) => q.isActive == false).toList();
      // }

      // Load statistics if level is selected
      Map<String, dynamic> stats = {};
      if (_selectedLevel != null) {
        stats = await _questionBankService.getStatistics(_selectedLevel!);
      }

      setState(() {
        _questions = questions;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa câu hỏi này?\n\nID: ${question.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _questionBankService.deleteQuestion(
          hskLevel: question.hskLevel,
          section: question.section,
          questionType: question.type,
          questionId: question.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã xóa câu hỏi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // TODO: Implement toggleActive in hierarchical service
  Future<void> _toggleActive(QuestionModel question) async {
    try {
      // TODO: Implement toggleActive in hierarchical service
      // await _questionBankService.toggleActive(...);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Toggle active (TODO)'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân Hàng Câu Hỏi HSK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_selectedLevel != null && _statistics.isNotEmpty)
            _buildStatistics(),
          Expanded(child: _buildQuestionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditQuestionScreen(
                hskLevel: _selectedLevel,
              ),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Câu Hỏi'),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // HSK Level
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<int?>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'HSK Level',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tất cả')),
                      ...List.generate(6, (i) => i + 1).map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text('HSK $level'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedLevel = value);
                      _loadData();
                    },
                  ),
                ),
                // Section
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String?>(
                    value: _selectedSection,
                    decoration: const InputDecoration(
                      labelText: 'Phần',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'nghe', child: Text('Nghe')),
                      DropdownMenuItem(value: 'doc', child: Text('Đọc')),
                      DropdownMenuItem(value: 'viet', child: Text('Viết')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSection = value;
                        // Reset question type if section changed
                        if (_selectedType != null) {
                          if (value == null) {
                            // If section cleared, keep type as is (show all)
                          } else {
                            // If section selected, check if type matches
                            final typeStr = _selectedType.toString().split('.').last;
                            if (!typeStr.startsWith(value)) {
                              _selectedType = null; // Reset if mismatch
                            }
                          }
                        }
                      });
                      _loadData();
                    },
                  ),
                ),
                // Question Type (from HSK structure - in correct order)
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<QuestionType?>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Loại câu hỏi',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả', style: TextStyle(fontSize: 12)),
                      ),
                      // Get types from HSK structure (if level selected)
                      if (_selectedLevel != null)
                        ...HskStructure.getQuestionTypes(
                          _selectedLevel!,
                          _selectedSection,
                        ).map((type) {
                          // Get description from structure
                          final items = HskStructure.getStructure(_selectedLevel!)
                              .where((item) => item.type == type)
                              .toList();
                          
                          final desc = items.isNotEmpty
                              ? items.first.description
                              : type.toString().split('.').last.replaceAll('_', ' ');
                          
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              desc,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }),
                      // Fallback: show all types if no level selected
                      if (_selectedLevel == null)
                        ...QuestionType.values.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.toString().split('.').last.replaceAll('_', ' '),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                      _loadData();
                    },
                  ),
                ),
                // Show inactive
                FilterChip(
                  label: const Text('Chỉ câu đã ẩn'),
                  selected: _showInactiveOnly,
                  onSelected: (value) {
                    setState(() => _showInactiveOnly = value);
                    _loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Tổng', _statistics['total'] ?? 0, Colors.blue),
            _buildStatItem('Nghe', _statistics['nghe'] ?? 0, Colors.blue),
            _buildStatItem('Đọc', _statistics['doc'] ?? 0, Colors.green),
            _buildStatItem('Viết', _statistics['viet'] ?? 0, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildQuestionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có câu hỏi nào'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditQuestionScreen(
                      hskLevel: _selectedLevel,
                    ),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Câu Hỏi Đầu Tiên'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            // TODO: Add isActive field to QuestionModel for conditional styling
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getSectionColor(question.section),
                child: Text(
                  'HSK\n${question.hskLevel}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text(
                question.type.toString().split('.').last,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // Content display
                  Row(
                    children: [
                      if (question.content['audioUrl'] != null && question.content['audioUrl'].toString().isNotEmpty)
                        const Icon(Icons.volume_up, size: 18, color: Colors.blue),
                      if (question.content['imageUrl'] != null && question.content['imageUrl'].toString().isNotEmpty)
                        const Icon(Icons.image, size: 18, color: Colors.green),
                      if ((question.content['audioUrl'] != null && question.content['audioUrl'].toString().isNotEmpty) ||
                          (question.content['imageUrl'] != null && question.content['imageUrl'].toString().isNotEmpty))
                        const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (question.content['text'] ?? '').toString().isEmpty
                              ? '(Audio/Image only)'
                              : (question.content['text'] ?? '').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: (question.content['text'] ?? '').toString().isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                            color: (question.content['text'] ?? '').toString().isEmpty
                                ? Colors.grey[600]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Options display
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...question.options.take(3).map((opt) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: opt == question.correctAnswer
                                  ? Colors.green[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: opt == question.correctAnswer
                                    ? Colors.green
                                    : Colors.grey[400]!,
                              ),
                            ),
                            child: Text(
                              opt.length > 15 ? '${opt.substring(0, 15)}...' : opt,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: opt == question.correctAnswer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: opt == question.correctAnswer
                                    ? Colors.green[900]
                                    : Colors.black87,
                              ),
                            ),
                          )),
                      if (question.options.length > 3)
                        Text(
                          '+${question.options.length - 3}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSectionChip(question.section),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${question.id}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      // TODO: Add rangeGroup, usageCount, correctRate to QuestionModel if needed
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditQuestionScreen(
                            question: question,
                          ),
                        ),
                      ).then((result) {
                        if (result == true) _loadData();
                      });
                      break;
                    case 'toggle':
                      _toggleActive(question);
                      break;
                    case 'delete':
                      _deleteQuestion(question);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  // TODO: isActive not in QuestionModel
                  // PopupMenuItem(
                  //   value: 'toggle',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.visibility_off, size: 20),
                  //       SizedBox(width: 8),
                  //       Text('Toggle'),
                  //     ],
                  //   ),
                  // ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionChip(String section) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getSectionColor(section).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        section.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getSectionColor(section),
        ),
      ),
    );
  }

  Color _getSectionColor(String section) {
    switch (section) {
      case 'nghe':
        return Colors.blue;
      case 'doc':
        return Colors.green;
      case 'viet':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
