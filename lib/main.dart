import 'dart:math' as math;
import 'package:flutter/material.dart';

// Ponto de entrada da aplicação Flutter.
// Aqui a aplicação é iniciada com o widget principal da tela.
void main() => runApp(const SpaceApp());

// Classe responsável por montar o tema e a tela inicial do app.
class SpaceApp extends StatelessWidget {
  const SpaceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mapa Espacial!',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF080C17),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF79D7F2), brightness: Brightness.dark),
          fontFamily: 'Trebuchet MS',
        ),
        // Define a página principal do mapa espacial como tela inicial.
        home: const SpaceMapPage(),
      );
}

// Tela principal do sistema solar.
// Mantém o estado do zoom e do planeta selecionado.
class SpaceMapPage extends StatefulWidget {
  const SpaceMapPage({super.key});

  @override
  State<SpaceMapPage> createState() => _SpaceMapPageState();
}

class _SpaceMapPageState extends State<SpaceMapPage> {
  // Nível de zoom do mapa, usado para ampliar ou reduzir o sistema solar.
  double _zoom = 1;
  // Planeta atualmente selecionado para exibir detalhes no painel inferior.
  CelestialBody _selected = bodies[3];

  // Ajusta o zoom dentro de limites mínimos e máximos.
  void _changeZoom(double amount) => setState(() => _zoom = (_zoom + amount).clamp(.65, 1.8));

  // Quando o usuário toca no mapa, identifica qual planeta está mais próximo do ponto clicado.
  void _tapMap(Offset point, Size size) {
    final center = Offset(size.width * .5, size.height * .52);
    CelestialBody? nearest;
    var distance = 34.0;
    for (final body in bodies) {
      final current = (point - center - body.offset * _zoom).distance;
      if (current < distance) {
        nearest = body;
        distance = current;
      }
    }
    if (nearest != null) setState(() => _selected = nearest!);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTapUp: (details) => _tapMap(details.localPosition, constraints.biggest),
                          child: CustomPaint(painter: SpacePainter(zoom: _zoom, selected: _selected)),
                        ),
                      ),
                      Positioned(left: 20, top: 18, child: _buildMapLabel()),
                      Positioned(right: 20, top: 18, child: _buildZoomControls()),
                      Positioned(left: 20, right: 20, bottom: 126, child: _buildPlanetSelector()),
                      Positioned(left: 20, right: 20, bottom: 20, child: _buildDetails()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // Cabeçalho da tela com ícone, título e ações rápidas.
  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Row(
          children: [
            const Icon(Icons.explore, color: Color(0xFF79D7F2), size: 28),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mapa Espacial!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Text('O Mapa do nosso Sistema Solar.', style: TextStyle(color: Color(0xFF8190AC), fontSize: 12)),
              ],
            ),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Color(0xFFB7C5DC)), tooltip: 'Buscar'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Color(0xFFB7C5DC)), tooltip: 'Filtros'),
          ],
        ),
      );

  // Etiqueta visual indicando que a área em destaque é o sistema solar.
  Widget _buildMapLabel() => const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xCC101A2B), borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(children: [Icon(Icons.circle, size: 8, color: Color(0xFF65E3AC)), SizedBox(width: 8), Text('SISTEMA SOLAR', style: TextStyle(fontSize: 11, letterSpacing: 1.3, fontWeight: FontWeight.bold))]),
        ),
      );

  // Botões para aproximar e afastar o mapa.
  Widget _buildZoomControls() => DecoratedBox(
        decoration: BoxDecoration(color: const Color(0xDD101A2B), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          IconButton(onPressed: () => _changeZoom(.15), icon: const Icon(Icons.add), tooltip: 'Aumentar zoom'),
          Text('${(_zoom * 100).round()}%', style: const TextStyle(fontSize: 11, color: Color(0xFF8190AC))),
          IconButton(onPressed: () => _changeZoom(-.15), icon: const Icon(Icons.remove), tooltip: 'Diminuir zoom'),
        ]),
      );

  // Lista horizontal com todos os planetas para fácil seleção.
  Widget _buildPlanetSelector() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: bodies
              .where((body) => body != bodies[0])
              .map((body) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(body.name),
                      selected: body == _selected,
                      selectedColor: body.color.withAlpha(60),
                      backgroundColor: const Color(0xFF101A2B),
                      side: BorderSide(color: body == _selected ? body.color : Colors.transparent),
                      labelStyle: TextStyle(
                        color: body == _selected ? Colors.white : const Color(0xFFB7C5DC),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selected = body),
                    ),
                  ))
              .toList(),
        ),
      );

  // Painel inferior com nome, descrição e distância do planeta selecionado.
  Widget _buildDetails() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: Container(
          key: ValueKey(_selected.name),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xF2162234), borderRadius: BorderRadius.circular(5), border: Border.all(color: _selected.color.withAlpha(110))),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: _selected.color.withAlpha(35)), child: Icon(_selected.icon, color: _selected.color, size: 27)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_selected.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(_selected.description, style: const TextStyle(color: Color(0xFF9BAAC1), fontSize: 12))])),
            Text(_selected.distance, style: TextStyle(color: _selected.color, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      );
}

// Modelo de dados para cada corpo celeste do sistema solar.
class CelestialBody {
  const CelestialBody(this.name, this.offset, this.color, this.icon, this.description, this.distance);
  final String name, description, distance;
  final Offset offset;
  final Color color;
  final IconData icon;
}

// Lista com os corpos que aparecem no mapa espacial.
const bodies = [
  CelestialBody('Sol', Offset(0, 0), Color(0xFFFFC857), Icons.wb_sunny, 'A estrela que ilumina e aquece o Sistema Solar', '0 km'),
  CelestialBody('Mercúrio', Offset(42, -16), Color(0xFFB7A58C), Icons.circle, 'Um Planeta pequeno, marcado por crateras antigas', '57,9 mi km'),
  CelestialBody('Vênus', Offset(88, 18), Color(0xFFD9C39B), Icons.circle, 'Um Planeta sufocante, envolto por nuvens de ácido sulfúrico', '108,2 mi km'),
  CelestialBody('Terra', Offset(150, -42), Color(0xFF5CC8F2), Icons.public, 'O único Planeta conhecido ondde a vida existe', '149,6 mi km'),
  CelestialBody('Marte', Offset(210, 72), Color(0xFFE8795B), Icons.circle, 'Um Planeta deserto, vermelho, com montanhas e possíveis vestígios de água', '227,9 mi km'),
  CelestialBody('Júpiter', Offset(-150, -105), Color(0xFFE5B77A), Icons.circle, 'Um gigante colossal com uma tempestade que dura séculos', '778,5 mi km'),
  CelestialBody('Saturno', Offset(-245, 150), Color(0xFFE9D09B), Icons.circle, 'Um gigante gasoso cercado por um dos espetáculos mais incríveis do espaço', '1,43 bi km'),
  CelestialBody('Urano', Offset(-310, -20), Color(0xFF9FE3FF), Icons.circle, 'Um Planeta congelado que praticamente não tem atividade geológica', '2,87 bi km'),
  CelestialBody('Netuno', Offset(-370, 82), Color(0xFF6EA8FF), Icons.circle, 'Um Planeta azul e congelante, açoitado por ventos extremamente velozes', '4,50 bi km'),
];

// Classe responsável por desenhar o fundo, as órbitas e os planetas no canvas.
class SpacePainter extends CustomPainter {
  SpacePainter({required this.zoom, required this.selected});
  final double zoom;
  final CelestialBody selected;

  @override
  void paint(Canvas canvas, Size size) {
    // Ponto central do mapa, usado como referência para posicionar os corpos celestes.
    final center = Offset(size.width * .5, size.height * .52);

    // Fundo de espaço com gradiente escuro para simular o céu noturno.
    final background = Paint()..shader = const RadialGradient(colors: [Color(0xFF182640), Color(0xFF080C17)], radius: 1.05).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    // Cria estrelas aleatórias para dar sensação de espaço profundo.
    final random = math.Random(12);
    for (var i = 0; i < 105; i++) {
      final point = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(point, random.nextDouble() * 1.5 + .3, Paint()..color = Colors.white.withAlpha(random.nextInt(130) + 50));
    }

    // Desenha as órbitas dos planetas em torno do Sol.
    final orbitPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x557D98B8);
    for (final radius in [58.0, 98.0, 152.0, 210.0, 272.0, 336.0, 410.0]) {
      canvas.drawOval(Rect.fromCenter(center: center, width: radius * 2.1 * zoom, height: radius * 1.25 * zoom), orbitPaint);
    }

    // Percorre todos os corpos celestes e os desenha no mapa.
    for (final body in bodies) {
      final point = center + body.offset * zoom;

      // Saturno recebe um anel adicional para diferenciar visualmente.
      if (body.name == 'Saturno') {
        canvas.save();
        canvas.translate(point.dx, point.dy);
        canvas.rotate(-.2);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 39, height: 13), Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = body.color.withAlpha(160));
        canvas.restore();
      }

      // Tamanho do planeta varia conforme o corpo celeste.
      final radius = switch (body.name) {
        'Sol' => 17.0,
        'Júpiter' => 11.0,
        'Saturno' => 9.0,
        'Urano' => 7.5,
        'Netuno' => 7.0,
        _ => 5.5,
      };

      // Sombra e corpo do planeta.
      canvas.drawCircle(point, radius * 1.5, Paint()..color = body.color.withAlpha(35));
      canvas.drawCircle(point, radius, Paint()..color = body.color);

      // Marca o planeta selecionado com um círculo externo.
      if (body == selected) canvas.drawCircle(point, radius + 10, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = body.color);

      // Exibe o nome do planeta ao lado do corpo, exceto do Sol.
      if (body != bodies[0]) _drawLabel(canvas, point, body.name, body.color);
    }
  }

  // Desenha o texto do nome do planeta no canvas.
  void _drawLabel(Canvas canvas, Offset point, String label, Color color) {
    final text = TextPainter(text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
    text.paint(canvas, point + const Offset(12, -7));
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => oldDelegate.zoom != zoom || oldDelegate.selected != selected;
}