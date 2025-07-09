import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:french_stream_downloader/src/core/routing/app_router.gr.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              Hero(tag: "icon", child: Image.asset("assets/icon/icon.jpeg")),
              Text(
                "Saisis le titre de ton film ou de ta série et laisse la magie opérer !",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: "Ex: squid game"),
              ),
              FilledButton.icon(
                onPressed: _onSearch,
                label: Text("Rechercher"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearch() {
    if (_controller.text.isNotEmpty) {
      AutoRouter.of(
        context,
      ).push(SearchResultRoute(query: _controller.text.trim()));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Veuillez saisir un titre")));
    }
  }
}
