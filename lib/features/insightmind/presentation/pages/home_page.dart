1 // lib/features/insightmind/presentation/pages/home_page.dart
2 import 'package:flutter/material.dart';
3 import 'package:flutter_riverpod/flutter_riverpod.dart';
4 import '../providers/score_provider.dart';
5 import 'package:insightmind/routes/halaman_baru'
6 import 'result_page.dart'
7
8 class HomePage extends ConsumerWidget {
9   const HomePage({Key? key}) : super(key: key);
10
11   @override
12   Widget build(BuildContext context, WidgetRef ref) {
13     final answersProvider = ref.watch(answersProvider);
14
15     return Scaffold(
16       appBar: AppBar(
17         title: const Text('InsightMind - Home'),
18         backgroundColor: Colors.indigo,
19         foregroundColor: Colors.white,
20         centerTitle: true,
21       ),
22       body: Padding(
23         padding: const EdgeInsets.all(16),
24         child: Column(
25           crossAxisAlignment: CrossAxisAlignment.center,
26           children: [
27             const Text(
28               'Selamat datang di aplikasi InsightMind\n\n'
29               'Latihan Mindful di mana saja dan kapanpun.\n'
30               'Fokus, meditasi, dan kembangkan diri sekarang.\n'
31               'Instruksi yang mudah dan sederhana dan cepat.',
32               textAlign: TextAlign.center,
33               style: TextStyle(fontSize: 16),
34             ),
35             const SizedBox(height: 24),
36
37             // Tombol menuju ScreeningPage
38             SizedBox(
39               width: double.infinity,
40               height: 50, // Ukuran tombol
41               child: FilledButton.icon(
42                 icon: const Icon(Icons.psychology_alt),
43                 label: const Text('Mulai Tes Kesiapan Diri'),
44                 style: FilledButton.styleFrom(
45                   backgroundColor: Colors.indigo,
46                   padding: const EdgeInsets.symmetric(vertical: 16),
47                 ),
48                 onPressed: () {
49                   Navigator.push(
50                     context,
51                     MaterialPageRoute(builder: (__) => const ScreeningPage()),
52                   );
53                 },
54               ),
55             ),
56
57             const SizedBox(height: 32),
58             const Divider(thickness: 1),
59
60             // Text untuk hasil terakhir
61             const Text(
62               'Jawaban terakhir (minggu 2 (masih bisa dipakai latihan)',
63               style: TextStyle(fontWeight: FontWeight.bold),
64             ),
65             Wrap(
66               spacing: 8,
67               children: [
68                 for (int i = 0; i < answers.length; i++)
69                   Chip(label: Text('${answers[i]}')),
70               ],
71             ),
72           ],
73         ),
74       ),
75       floatingActionButton: FloatingActionButton(
76         backgroundColor: Colors.indigo,
77         foregroundColor: Colors.white,
78         onPressed: () {
79           // Tambah data dummy (latihan minggu)
80           final now = DateTime.now().millisecondsSinceEpoch % 4).toInt();
81           final current = [...ref.read(answersProvider)];
82           current.add(now);
83           ref.read(answersProvider.notifier).state = current;
84         },
85         child: const Icon(Icons.add),
86       ),
87     );
88   }
89 }