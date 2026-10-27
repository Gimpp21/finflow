import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
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

  Transacao({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.isReceita,
  });

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'titulo': titulo,
    'subtitulo': subtitulo,
    'valor': valor,
    'isReceita': isReceita,
  };

  factory Transacao.fromJson(Map<String, dynamic> json) => Transacao(
    icon: json['icon'],
    titulo: json['titulo'],
    subtitulo: json['subtitulo'],
    valor: json['valor'],
    isReceita: json['isReceita'],
  );
}

// Splash Screen
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
            pageBuilder: (_, __, ___) => const LoginScreen(),
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
                  width: 90,
                  height: 90,
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
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '₿',
                      style: TextStyle(fontSize: 40, color: Color(0xFF080C14)),
                    ),
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

// Login Screen
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

// Home Page
class HomePage extends StatefulWidget {
  final String nome;
  const HomePage({super.key, required this.nome});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transacao> _transacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('transacoes');
    if (dados != null) {
      final lista = jsonDecode(dados) as List;
      setState(() {
        _transacoes.addAll(lista.map((e) => Transacao.fromJson(e)));
      });
    } else {
      setState(() {
        _transacoes.addAll([
          Transacao(
            icon: '🛒',
            titulo: 'Supermercado',
            subtitulo: 'Hoje, 09:30',
            valor: 320,
            isReceita: false,
          ),
          Transacao(
            icon: '💼',
            titulo: 'Salário',
            subtitulo: 'Ontem, 08:00',
            valor: 3200,
            isReceita: true,
          ),
          Transacao(
            icon: '⚡',
            titulo: 'Conta de luz',
            subtitulo: '25 Mai, 14:00',
            valor: 180,
            isReceita: false,
          ),
          Transacao(
            icon: '🍔',
            titulo: 'Restaurante',
            subtitulo: '24 Mai, 20:15',
            valor: 85,
            isReceita: false,
          ),
          Transacao(
            icon: '📱',
            titulo: 'Internet',
            subtitulo: '23 Mai, 11:00',
            valor: 165,
            isReceita: false,
          ),
        ]);
      });
    }
  }

  Future<void> _salvarTransacoes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'transacoes',
      jsonEncode(_transacoes.map((t) => t.toJson()).toList()),
    );
  }

  double get _totalReceitas =>
      _transacoes.where((t) => t.isReceita).fold(0, (s, t) => s + t.valor);

  double get _totalDespesas =>
      _transacoes.where((t) => !t.isReceita).fold(0, (s, t) => s + t.valor);

  double get _saldo => _totalReceitas - _totalDespesas;

  void _deletarTransacao(int index) {
    setState(() => _transacoes.removeAt(index));
    _salvarTransacoes();
  }

  void _abrirFormulario() {
    final tituloCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    bool isReceita = false;

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
                      Container(
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
                    child: Text(
                      'R\$ ${_saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
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
                return Dismissible(
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
                    subtitulo: t.subtitulo,
                    valor:
                        '${t.isReceita ? '+' : '-'} R\$ ${t.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                    cor: t.isReceita
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFFFF6B6B),
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
