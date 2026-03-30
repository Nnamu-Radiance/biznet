import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../../providers/business_provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String businessId;

  const BusinessProfileScreen({Key? key, required this.businessId}) : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).fetchBusinessDetails(widget.businessId);
    });
  }

  Future<void> _copyToClipboard(String text, String message) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to copy to clipboard')));
    }
  }

  String _ensureUrl(String value, {String? fallbackHost}) {
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (fallbackHost != null) return 'https://$fallbackHost/${value.replaceAll('@', '')}';
    return 'https://${value.replaceAll('@', '')}';
  }

  void _showContactOptions(BuildContext ctx, dynamic business) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) {
        final items = <Widget>[];

        if (business.ecommerceLink != null && business.ecommerceLink!.trim().isNotEmpty) {
          final link = _ensureUrl(business.ecommerceLink!.trim());
          items.add(ListTile(
            leading: const Icon(LucideIcons.shoppingCart, color: Color(0xFF1E2E4F)),
            title: const Text('Shop Online'),
            subtitle: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.pop(sheetCtx);
              _copyToClipboard(link, 'Ecommerce link copied to clipboard');
            },
            trailing: IconButton(
              icon: const Icon(LucideIcons.copy),
              onPressed: () {
                _copyToClipboard(link, 'Ecommerce link copied to clipboard');
                Navigator.pop(sheetCtx);
              },
            ),
          ));
        }

        if (business.instagram != null && business.instagram!.trim().isNotEmpty) {
          final handle = business.instagram!.trim();
          final link = _ensureUrl(handle, fallbackHost: 'instagram.com');
          items.add(ListTile(
            leading: const Icon(LucideIcons.instagram, color: Colors.purple),
            title: const Text('Instagram'),
            subtitle: Text(handle, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.pop(sheetCtx);
              _copyToClipboard(link, 'Instagram link copied to clipboard');
            },
            trailing: IconButton(
              icon: const Icon(LucideIcons.copy),
              onPressed: () {
                _copyToClipboard(handle, 'Instagram handle copied to clipboard');
                Navigator.pop(sheetCtx);
              },
            ),
          ));
        }

        if (business.twitter != null && business.twitter!.trim().isNotEmpty) {
          final handle = business.twitter!.trim();
          final link = _ensureUrl(handle, fallbackHost: 'twitter.com');
          items.add(ListTile(
            leading: const Icon(LucideIcons.twitter, color: Colors.lightBlue),
            title: const Text('Twitter'),
            subtitle: Text(handle, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.pop(sheetCtx);
              _copyToClipboard(link, 'Twitter link copied to clipboard');
            },
            trailing: IconButton(
              icon: const Icon(LucideIcons.copy),
              onPressed: () {
                _copyToClipboard(handle, 'Twitter handle copied to clipboard');
                Navigator.pop(sheetCtx);
              },
            ),
          ));
        }

        if (business.facebook != null && business.facebook!.trim().isNotEmpty) {
          final fb = business.facebook!.trim();
          final link = _ensureUrl(fb, fallbackHost: 'facebook.com');
          items.add(ListTile(
            leading: const Icon(LucideIcons.facebook, color: Colors.blue),
            title: const Text('Facebook'),
            subtitle: Text(fb, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.pop(sheetCtx);
              _copyToClipboard(link, 'Facebook link copied to clipboard');
            },
            trailing: IconButton(
              icon: const Icon(LucideIcons.copy),
              onPressed: () {
                _copyToClipboard(fb, 'Facebook handle copied to clipboard');
                Navigator.pop(sheetCtx);
              },
            ),
          ));
        }

        if (items.isEmpty) {
          items.add(Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(LucideIcons.info, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No contact links available for this business.'),
              ],
            ),
          ));
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(alignment: Alignment.centerLeft, child: Text('Contact ${business.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ),
              ...items,
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final business = businessProvider.currentBusiness;

    if (businessProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (businessProvider.error != null) {
      return Scaffold(body: Center(child: Text(businessProvider.error!)));
    }

    if (business == null) {
      return const Scaffold(body: Center(child: Text('Business not found')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(business.name, style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white, fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (business.logoUrl != null && business.logoUrl!.trim().isNotEmpty)
                    Image.network(business.logoUrl!, fit: BoxFit.cover)
                  else
                    Image.asset('assets/app_logo.png', fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Theme.of(context).brightness == Brightness.dark ? Colors.black54 : const Color.fromRGBO(0, 0, 0, 0.7)]))),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(LucideIcons.share2), onPressed: () => _copyToClipboard('https://biznet.app/business/${business.id}', 'Business link copied to clipboard')),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.green.withValues(alpha: 0.08) : Colors.green[50], borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [Icon(LucideIcons.shieldCheck, size: 16, color: Colors.green), const SizedBox(width: 4), Text('Trust Score: ${business.trustScore.toStringAsFixed(1)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                  ),
                  if (business.ecommerceLink != null)
                    ElevatedButton.icon(onPressed: () => _showContactOptions(context, business), icon: const Icon(LucideIcons.shoppingCart, size: 18), label: const Text('Shop Online'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))
                ]),
                const SizedBox(height: 16),
                Text(business.description ?? 'No description available.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.85), fontSize: 16)),
                const SizedBox(height: 24),
                const Divider(),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (businessProvider.products.isEmpty)
                  const Text('No products listed yet.')
                else
                  SizedBox(height: 180, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: businessProvider.products.length, itemBuilder: (context, index) {
                    final product = businessProvider.products[index];
                    return GestureDetector(
                      onTap: () {
                        final productName = Uri.encodeComponent(product.name);
                        context.push('/write-review/${business.id}/${business.name}?productId=${product.id}&productName=$productName');
                      },
                      child: Container(width: 140, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: product.imageUrl != null ? Image.network(product.imageUrl!, height: 100, width: 140, fit: BoxFit.cover) : Container(height: 100, color: Theme.of(context).dividerColor, child: Icon(LucideIcons.image, color: Theme.of(context).iconTheme.color))), Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))]))])),
                    );
                  })),
                const SizedBox(height: 24),
                const Divider(),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton.icon(onPressed: () => context.push('/write-review/${business.id}/${business.name}'), icon: Icon(LucideIcons.edit, size: 16, color: Theme.of(context).colorScheme.primary), label: const Text('Write a Review'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary))
                ]),
                const SizedBox(height: 16),
                if (businessProvider.reviews.isEmpty)
                  const Text('No reviews yet. Be the first to review!')
                else
                  ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: businessProvider.reviews.length, itemBuilder: (context, index) {
                    final review = businessProvider.reviews[index];
                    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), child: Icon(LucideIcons.user, color: Theme.of(context).colorScheme.primary, size: 20)), const SizedBox(width: 12), Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))]), Row(children: [const Icon(LucideIcons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(review.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold))])]), const SizedBox(height: 12), Text(review.text, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)), const SizedBox(height: 16), Row(children: [TextButton(onPressed: () {}, child: Text('Reply', style: TextStyle(color: Theme.of(context).colorScheme.primary))), const Spacer(), Text(DateFormat('MMM d, yyyy').format(review.createdAt), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 12))])]));
                  })
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
