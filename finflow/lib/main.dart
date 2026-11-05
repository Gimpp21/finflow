import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FinFlowApp());
}

class FinFlowApp extends StatelessWidget {
  const FinFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3A6B)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Modelo de transação
class Transacao {
  final String icon;
  final String titulo;
  final String subtitulo;
  final double valor;
  final bool isReceita;
  final String categoria;

  Transacao({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.isReceita,
    this.categoria = 'Outros',
  });

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'titulo': titulo,
    'subtitulo': subtitulo,
    'valor': valor,
    'isReceita': isReceita,
    'categoria': categoria,
  };

  factory Transacao.fromJson(Map<String, dynamic> json) => Transacao(
    icon: json['icon'],
    titulo: json['titulo'],
    subtitulo: json['subtitulo'],
    valor: (json['valor'] as num).toDouble(),
    isReceita: json['isReceita'],
    categoria: json['categoria'] ?? 'Outros',
  );
}

// ---------------- SPLASH ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return const AuthScreen();
              final nome =
                  (user.displayName != null && user.displayName!.isNotEmpty)
                  ? user.displayName!
                  : (user.email ?? 'Usuário').split('@').first;
              return HomePage(nome: nome, uid: user.uid);
            },
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0A1628),
                    border: Border.all(
                      color: const Color(0xFFC9A84C),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9A84C).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/icon/icon_foreground.png'),
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                  ).createShader(bounds),
                  child: const Text(
                    'FinFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu dinheiro, sob controle',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- LOGIN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nomeCtrl = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nomeCtrl.dispose();
    super.dispose();
  }

  void _entrar() async {
    if (_nomeCtrl.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', _nomeCtrl.text.trim());
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomePage(nome: _nomeCtrl.text.trim()),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                  ).createShader(bounds),
                  child: const Text(
                    'Bem-vindo\nao FinFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Como podemos te chamar?',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 15),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nomeCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Seu nome',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0xFF0E1520),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFC9A84C),
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFFC9A84C),
                    ),
                  ),
                  onSubmitted: (_) => _entrar(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _entrar,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC9A84C).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          color: Color(0xFF080C14),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- HOME ----------------
class HomePage extends StatefulWidget {
  final String nome;
  final String uid;
  const HomePage({super.key, required this.nome, this.uid = ''});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transacao> _transacoes = [];
  String get _chave => widget.uid.isNotEmpty
      ? 'transacoes_${widget.uid}'
      : 'transacoes_${widget.nome.trim().toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  DocumentReference<Map<String, dynamic>>? get _doc => widget.uid.isEmpty
      ? null
      : FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .collection('dados')
            .doc('transacoes');

  Future<void> _carregarTransacoes() async {
    List? lista;
    bool veioDoCelular = false;

    try {
      final snap = await _doc?.get();
      if (snap != null && snap.exists) {
        lista = snap.data()?['lista'] as List?;
      }
    } catch (_) {}

    if (lista == null) {
      final prefs = await SharedPreferences.getInstance();
      final dados = prefs.getString(_chave);
      if (dados != null) {
        lista = jsonDecode(dados) as List;
        veioDoCelular = true;
      }
    }

    if (!mounted) return;
    final dadosFinais = lista;
    setState(() {
      if (dadosFinais != null) {
        _transacoes.addAll(
          dadosFinais.map(
            (e) => Transacao.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
      } else {
        _transacoes.addAll([
          Transacao(
            icon: '🛒',
            titulo: 'Supermercado',
            subtitulo: 'Hoje, 09:30',
            valor: 320,
            isReceita: false,
            categoria: 'Alimentação',
          ),
          Transacao(
            icon: '💼',
            titulo: 'Salário',
            subtitulo: 'Ontem, 08:00',
            valor: 3200,
            isReceita: true,
            categoria: 'Salário',
          ),
          Transacao(
            icon: '⚡',
            titulo: 'Conta de luz',
            subtitulo: '25 Mai, 14:00',
            valor: 180,
            isReceita: false,
            categoria: 'Moradia',
          ),
          Transacao(
            icon: '🍔',
            titulo: 'Restaurante',
            subtitulo: '24 Mai, 20:15',
            valor: 85,
            isReceita: false,
            categoria: 'Alimentação',
          ),
          Transacao(
            icon: '📱',
            titulo: 'Internet',
            subtitulo: '23 Mai, 11:00',
            valor: 165,
            isReceita: false,
            categoria: 'Moradia',
          ),
        ]);
      }
    });
    if (veioDoCelular) _salvarTransacoes();
  }

  Future<void> _salvarTransacoes() async {
    final json = _transacoes.map((t) => t.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(json));
    try {
      await _doc?.set({'lista': json});
    } catch (_) {}
  }

  double get _totalReceitas =>
      _transacoes.where((t) => t.isReceita).fold(0, (s, t) => s + t.valor);

  double get _totalDespesas =>
      _transacoes.where((t) => !t.isReceita).fold(0, (s, t) => s + t.valor);

  double get _saldo => _totalReceitas - _totalDespesas;
  Map<String, double> get _gastosPorCategoria {
    final mapa = <String, double>{};
    for (final t in _transacoes.where((t) => !t.isReceita)) {
      mapa[t.categoria] = (mapa[t.categoria] ?? 0) + t.valor;
    }
    return mapa;
  }

  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _deletarTransacao(int index) {
    setState(() => _transacoes.removeAt(index));
    _salvarTransacoes();
  }

  void _abrirFormulario() {
    final tituloCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    bool isReceita = false;
    String categoria = 'Outros';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                ).createShader(bounds),
                child: const Text(
                  'Nova Transação',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isReceita = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isReceita
                              ? const Color(0xFF4FC3F7).withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReceita
                                ? const Color(0xFF4FC3F7)
                                : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '💰 Receita',
                            style: TextStyle(
                              color: isReceita
                                  ? const Color(0xFF4FC3F7)
                                  : Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => isReceita = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isReceita
                              ? const Color(0xFFFF6B6B).withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !isReceita
                                ? const Color(0xFFFF6B6B)
                                : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '💸 Despesa',
                            style: TextStyle(
                              color: !isReceita
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          'Alimentação',
                          'Moradia',
                          'Transporte',
                          'Lazer',
                          'Salário',
                          'Outros',
                        ]
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setModalState(() => categoria = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: categoria == c
                                    ? const Color(0xFFC9A84C).withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: categoria == c
                                      ? const Color(0xFFC9A84C)
                                      : Colors.white12,
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: categoria == c
                                      ? const Color(0xFFC9A84C)
                                      : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tituloCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  final titulo = tituloCtrl.text.trim();
                  final valor = double.tryParse(valorCtrl.text.trim()) ?? 0;
                  if (titulo.isEmpty || valor <= 0) return;
                  setState(() {
                    _transacoes.insert(
                      0,
                      Transacao(
                        icon: isReceita ? '💰' : '💸',
                        titulo: titulo,
                        subtitulo: 'Agora',
                        valor: valor,
                        isReceita: isReceita,
                        categoria: categoria,
                      ),
                    );
                  });
                  _salvarTransacoes();
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC9A84C).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        color: Color(0xFF080C14),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A1628),
                    Color(0xFF1A3A6B),
                    Color(0xFF0A1628),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66C9A84C),
                    blurRadius: 30,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, ${widget.nome} 👋',
                            style: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                            ).createShader(bounds),
                            child: const Text(
                              'FinFlow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        color: const Color(0xFF0E1520),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        offset: const Offset(0, 52),
                        onSelected: (v) {
                          if (v == 'sair') _sair();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(
                              FirebaseAuth.instance.currentUser?.email ??
                                  widget.nome,
                              style: const TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'sair',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color(0xFFFF6B6B),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Sair',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.nome.isNotEmpty
                                  ? widget.nome[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Color(0xFF080C14),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Saldo disponível',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFC9A84C),
                        Color(0xFFFFE08A),
                        Color(0xFFC9A84C),
                      ],
                    ).createShader(bounds),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _saldo),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, valor, _) => Text(
                        'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniCard(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Receitas',
                          valor: 'R\$ ${_totalReceitas.toStringAsFixed(0)}',
                          iconColor: const Color(0xFF4FC3F7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Despesas',
                          valor: 'R\$ ${_totalDespesas.toStringAsFixed(0)}',
                          iconColor: const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _GraficoCategorias(dados: _gastosPorCategoria),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transações recentes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFC9A84C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final t = _transacoes[i];
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (i < 6 ? i : 6) * 100),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - v)),
                      child: child,
                    ),
                  ),
                  child: Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deletarTransacao(i),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFFF6B6B),
                        size: 26,
                      ),
                    ),
                    child: _ItemTransacao(
                      icon: t.icon,
                      titulo: t.titulo,
                      subtitulo: '${t.categoria} • ${t.subtitulo}',
                      valor:
                          '${t.isReceita ? '+' : '-'} R\$ ${t.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                      cor: t.isReceita
                          ? const Color(0xFF4FC3F7)
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                );
              }, childCount: _transacoes.length),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC9A84C).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _abrirFormulario,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Color(0xFF080C14), size: 28),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color iconColor;

  const _MiniCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemTransacao extends StatelessWidget {
  final String icon;
  final String titulo;
  final String subtitulo;
  final String valor;
  final Color cor;

  const _ItemTransacao({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1520),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficoCategorias extends StatelessWidget {
  final Map<String, double> dados;
  const _GraficoCategorias({required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) return const SizedBox.shrink();
    final total = dados.values.fold<double>(0, (s, v) => s + v);
    final itens = dados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1520),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por categoria',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...itens.map((e) {
            final pct = total == 0 ? 0.0 : e.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'R\$ ${e.value.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          color: Colors.white.withOpacity(0.06),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => FractionallySizedBox(
                            widthFactor: v.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFC9A84C),
                                    Color(0xFFFFE08A),
                                  ],
                                ),
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
          }),
        ],
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _criarConta = false;
  bool _carregando = false;
  bool _verSenha = false;
  String? _erro;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  String _traduzErro(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Esse e-mail já tem conta.';
      case 'weak-password':
        return 'Senha fraca. Use 6 caracteres ou mais.';
      case 'network-request-failed':
        return 'Sem internet. Tente de novo.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco.';
      default:
        return 'Algo deu errado. Tente de novo.';
    }
  }

  Future<void> _enviar() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    final nome = _nomeCtrl.text.trim();
    if (email.isEmpty || senha.isEmpty || (_criarConta && nome.isEmpty)) {
      setState(() => _erro = 'Preencha todos os campos.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      UserCredential cred;
      if (_criarConta) {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
        await cred.user?.updateDisplayName(nome);
      } else {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
      }
      final user = cred.user!;
      final nomeFinal =
          (user.displayName != null && user.displayName!.isNotEmpty)
          ? user.displayName!
          : (nome.isNotEmpty ? nome : email.split('@').first);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomePage(nome: nomeFinal, uid: user.uid),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _erro = _traduzErro(e.code));
    } catch (_) {
      setState(() => _erro = 'Algo deu errado. Tente de novo.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      filled: true,
      fillColor: const Color(0xFF0E1520),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFC9A84C)),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/icon/icon_foreground.png',
                    width: 110,
                    height: 110,
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                  ).createShader(bounds),
                  child: Text(
                    _criarConta ? 'Criar conta' : 'Bem-vindo\nde volta',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _criarConta
                      ? 'Leva menos de um minuto.'
                      : 'Entre para ver suas finanças.',
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),
                if (_criarConta) ...[
                  TextField(
                    controller: _nomeCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _deco('Seu nome', Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('E-mail', Icons.mail_outline),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _senhaCtrl,
                  obscureText: !_verSenha,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _enviar(),
                  decoration: _deco(
                    'Senha',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _verSenha ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFFAAAAAA),
                      ),
                      onPressed: () => setState(() => _verSenha = !_verSenha),
                    ),
                  ),
                ),
                if (_erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _erro!,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _carregando ? null : _enviar,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC9A84C), Color(0xFFFFE08A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC9A84C).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _carregando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF080C14),
                              ),
                            )
                          : Text(
                              _criarConta ? 'Criar conta' : 'Entrar',
                              style: const TextStyle(
                                color: Color(0xFF080C14),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _criarConta = !_criarConta;
                      _erro = null;
                    }),
                    child: Text(
                      _criarConta ? 'Já tenho conta' : 'Criar conta nova',
                      style: const TextStyle(
                        color: Color(0xFFC9A84C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
