import 'package:flutter/material.dart';
import '../../core/constants/il_kodlari.dart';

class IlSeciciWidget extends StatefulWidget {
  final String? seciliIlKodu;
  final ValueChanged<String> onIlSecildi;
  final String? hintText;

  const IlSeciciWidget({
    super.key,
    this.seciliIlKodu,
    required this.onIlSecildi,
    this.hintText,
  });

  @override
  State<IlSeciciWidget> createState() => _IlSeciciWidgetState();
}

class _IlSeciciWidgetState extends State<IlSeciciWidget> {
  final _controller = TextEditingController();
  String _aramaMetni = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> get _filtrelenmisIller {
    final iller = IlKodlari.sortedByName;
    if (_aramaMetni.isEmpty) return iller;
    final lower = _aramaMetni.toLowerCase();
    return iller.where((e) => e.value.toLowerCase().contains(lower)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'İl ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) => setState(() => _aramaMetni = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtrelenmisIller.length,
            itemBuilder: (context, index) {
              final il = _filtrelenmisIller[index];
              final isSelected = il.key == widget.seciliIlKodu;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[200],
                  child: Text(
                    il.key.padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                title: Text(il.value),
                selected: isSelected,
                onTap: () => widget.onIlSecildi(il.key),
              );
            },
          ),
        ),
      ],
    );
  }
}
