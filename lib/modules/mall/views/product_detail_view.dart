import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constant.dart';
import '../../../model/product_model.dart';
import '../controllers/mall_controller.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({required this.item, super.key});

  final MallProductItem item;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final MallController _controller = Get.find<MallController>();
  final PageController _pageController = PageController();
  int _quantity = 1;
  int _selectedImageIndex = 0;

  ProductModel get _product => widget.item.product;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int maxQuantity = _product.stock.toInt();
    final List<ProductImageModel> images = _product.displayImages;

    return Scaffold(
      backgroundColor: AppConstant.appColorSurface,
      appBar: AppBar(title: const Text('รายละเอียดสินค้า')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppConstant.appColorBorder)),
          ),
          child: Row(
            children: [
              _QuantityStepper(
                quantity: _quantity,
                maxQuantity: maxQuantity,
                onChanged: (quantity) => setState(() => _quantity = quantity),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => FilledButton.icon(
                    onPressed:
                        widget.item.isOutOfStock ||
                            _controller.isAddingToCart.value
                        ? null
                        : _addToCart,
                    icon: _controller.isAddingToCart.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(
                      widget.item.isOutOfStock ? 'สินค้าหมด' : 'เพิ่มลงตะกร้า',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ImageGallery(
              images: images,
              pageController: _pageController,
              selectedIndex: _selectedImageIndex,
              onPageChanged: (index) =>
                  setState(() => _selectedImageIndex = index),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: _product.category.trim().isEmpty
                            ? 'General'
                            : _product.category,
                      ),
                      _StockChip(item: widget.item),
                      if (_product.isRecommended)
                        const _InfoChip(
                          icon: Icons.star_rounded,
                          label: 'สินค้าแนะนำ',
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppConstant.appColorDeep,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_controller.formatCurrency(_product.price)}/${_product.unit}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppConstant.appColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'รายละเอียด',
                    text: _product.fullDescription.isEmpty
                        ? 'ไม่มีรายละเอียดสินค้า'
                        : _product.fullDescription,
                  ),
                  if (_product.condition.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'เงื่อนไขสินค้า',
                      text: _product.condition.trim(),
                    ),
                  ],
                  if (_product.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _product.tags
                          .map((tag) => _TagPill(label: tag))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'คงเหลือ $maxQuantity ${_product.unit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstant.appColorMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    final bool added = await _controller.addToCart(
      item: widget.item,
      quantity: _quantity,
    );

    if (!mounted || !added) {
      return;
    }

    Get.snackbar(
      'เพิ่มลงตะกร้าแล้ว',
      '${_product.name} จำนวน $_quantity ${_product.unit}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  final List<ProductImageModel> images;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          if (images.isEmpty)
            Container(
              color: AppConstant.appColorSoft,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  color: AppConstant.appColorMuted,
                  size: 58,
                ),
              ),
            )
          else
            PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final Uint8List? bytes = images[index].imageBytes;
                if (bytes == null) {
                  return Container(
                    color: AppConstant.appColorSoft,
                    child: const Icon(Icons.image_not_supported_rounded),
                  );
                }

                return Image.memory(bytes, fit: BoxFit.cover);
              },
              itemCount: images.length,
            ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(images.length, (index) {
                  final bool selected = index == selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity <= 1 ? null : () => onChanged(quantity - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: quantity >= maxQuantity
                ? null
                : () => onChanged(quantity + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppConstant.appColorDeep,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstant.appColorMuted,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppConstant.appColorSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppConstant.appColorDark),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppConstant.appColorDark,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.item});

  final MallProductItem item;

  @override
  Widget build(BuildContext context) {
    final String label = item.isOutOfStock
        ? 'หมด'
        : item.isLowStock
        ? 'ใกล้หมด'
        : 'พร้อมขาย';
    return _InfoChip(icon: Icons.inventory_2_outlined, label: label);
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          '#$label',
          style: const TextStyle(
            color: AppConstant.appColorMuted,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
