import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/search_provider.dart';
import '../widgets/business_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;

  const SearchScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
        provider.searchByCategory(widget.initialCategory!);
        _searchController.text = 'Category: ${widget.initialCategory}';
      } else {
        provider.loadAllBusinesses();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onBackground,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.length >= 3) {
                    searchProvider.search(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for businesses...',
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      searchProvider.clearSearch();
                    },
                  )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: searchProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchProvider.searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    searchProvider.query.isEmpty
                        ? 'Search for your favorite beauty spot'
                        : 'No results found for "${searchProvider.query}"',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: searchProvider.searchResults.length,
              itemBuilder: (context, index) {
                final business = searchProvider.searchResults[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BusinessCard(
                    business: business,
                    onTap: () => context.push('/business/${business.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
