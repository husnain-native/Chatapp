import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';
import 'package:park_chatapp/features/property/presentation/widgets/property_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:park_chatapp/features/property/presentation/screens/property_detail_screen.dart';

class PropertyExploreScreen extends StatefulWidget {
  final PropertyType? initialCategory;

  const PropertyExploreScreen({super.key, this.initialCategory});

  @override
  State<PropertyExploreScreen> createState() => _PropertyExploreScreenState();
}

class _PropertyExploreScreenState extends State<PropertyExploreScreen>
    with TickerProviderStateMixin {
  late TabController _priceController;
  late TabController _categoryController;

  String _searchText = '';
  PropertyType? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;

  // Filter and sort variables
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  double? _minArea;
  double? _maxArea;
  PropertyStatus? _selectedStatus;
  String _sortBy = 'newest';

  final List<Property> _properties = [
    Property(
      id: '1',
      title: 'Modern Apartment in Park View',
      description:
          'Beautiful 2-bedroom apartment with modern amenities, located in the heart of Park View City. Close to parks and shopping centers.',
      price: 25000000,
      type: PropertyType.residential,
      status: PropertyStatus.available,
      location: 'Park View City, Sector A',
      bedrooms: 2,
      bathrooms: 2,
      area: 1200,
      imageUrls: ['assets/images/apr1.jpg'],
      agentName: 'Ahmed Ali',
      agentId: 'agent1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isFeatured: true,
    ),
    Property(
      id: '2',
      title: 'Commercial Space in Park View',
      description:
          'Prime location commercial property for business in Park View City. High foot traffic area with excellent visibility.',
      price: 45000000,
      type: PropertyType.commercial,
      status: PropertyStatus.sold,
      location: 'Park View City, Commercial District',
      bedrooms: 0,
      bathrooms: 2,
      area: 2500,
      imageUrls: ['assets/images/com.jpeg'],
      agentName: 'Fatima Khan',
      agentId: 'agent2',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Property(
      id: '3',
      title: 'Luxury Villa for Rent',
      description:
          'Spacious 4-bedroom villa with garden and swimming pool. Perfect for families looking for luxury living in Park View City.',
      price: 150000,
      type: PropertyType.rent,
      status: PropertyStatus.rented,
      location: 'Park View City, Elite Block',
      bedrooms: 4,
      bathrooms: 4,
      area: 3500,
      imageUrls: ['assets/images/house3.webp'],
      agentName: 'Omar Hassan',
      agentId: 'agent3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Property(
      id: '4',
      title: 'Studio Apartment',
      description:
          'Cozy studio apartment in Park View City. Perfect for singles or couples. Includes all modern amenities.',
      price: 8500000,
      type: PropertyType.buy,
      status: PropertyStatus.available,
      location: 'Park View City, Sector B',
      bedrooms: 1,
      bathrooms: 1,
      area: 600,
      imageUrls: ['assets/images/apr2.jpg'],
      agentName: 'Zainab Ahmed',
      agentId: 'agent4',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Property(
      id: '5',
      title: 'Executive Penthouse',
      description:
          'Luxurious penthouse with panoramic views of Park View City. Features high-end finishes and premium amenities.',
      price: 75000000,
      type: PropertyType.residential,
      status: PropertyStatus.available,
      location: 'Park View City, Tower Heights',
      bedrooms: 3,
      bathrooms: 3,
      area: 2800,
      imageUrls: ['assets/images/house6.jpg'],
      agentName: 'Ahmed Ali',
      agentId: 'agent1',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      isFeatured: true,
    ),
    Property(
      id: '6',
      title: 'Retail Shop Space',
      description:
          'Well-located retail space in Park View City shopping arcade. Ideal for boutique, cafe, or specialty store.',
      price: 32000000,
      type: PropertyType.commercial,
      status: PropertyStatus.available,
      location: 'Park View City, Market Square',
      bedrooms: 0,
      bathrooms: 1,
      area: 1200,
      imageUrls: ['assets/images/retail1.jpg'],
      agentName: 'Fatima Khan',
      agentId: 'agent2',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Property(
      id: '7',
      title: 'Family Home for Rent',
      description:
          'Spacious family home with lawn and garage. Quiet neighborhood in Park View City. Available immediately.',
      price: 95000,
      type: PropertyType.rent,
      status: PropertyStatus.available,
      location: 'Park View City, Family Block',
      bedrooms: 3,
      bathrooms: 2,
      area: 2000,
      imageUrls: ['assets/images/house5.jpeg'],
      agentName: 'Omar Hassan',
      agentId: 'agent3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Property(
      id: '8',
      title: 'Investment Plot',
      description:
          'Prime investment plot in developing area of Park View City. Great potential for appreciation.',
      price: 12500000,
      type: PropertyType.buy,
      status: PropertyStatus.available,
      location: 'Park View City, Expansion Sector',
      bedrooms: 0,
      bathrooms: 0,
      area: 5000,
      imageUrls: ['assets/images/plot.jpeg'],
      agentName: 'Zainab Ahmed',
      agentId: 'agent4',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Property(
      id: '9',
      title: 'Luxury Apartment',
      description:
          'High-end apartment with premium finishes and concierge service. Best address in Park View City.',
      price: 42000000,
      type: PropertyType.residential,
      status: PropertyStatus.sold,
      location: 'Park View City, Luxury Towers',
      bedrooms: 2,
      bathrooms: 2,
      area: 1800,
      imageUrls: ['assets/images/apr3.jpg'],
      agentName: 'Ahmed Ali',
      agentId: 'agent1',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Property(
      id: '10',
      title: 'Office Space',
      description:
          'Modern office space with fiber internet and parking facilities. Ideal for professional services.',
      price: 38000000,
      type: PropertyType.commercial,
      status: PropertyStatus.available,
      location: 'Park View City, Business Center',
      bedrooms: 0,
      bathrooms: 2,
      area: 2200,
      imageUrls: ['assets/images/office.jpg'],
      agentName: 'Fatima Khan',
      agentId: 'agent2',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _priceController = TabController(length: 5, vsync: this);
    _categoryController = TabController(length: 4, vsync: this);

    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }

    _priceController.addListener(() {
      if (_priceController.indexIsChanging) return;
      setState(() {
        switch (_priceController.index) {
          case 0:
            _minPrice = null;
            _maxPrice = null;
            break;
          case 1:
            _minPrice = 5000000;
            _maxPrice = 10000000;
            break;
          case 2:
            _minPrice = 10000000;
            _maxPrice = 15000000;
            break;
          case 3:
            _minPrice = 15000000;
            _maxPrice = 20000000;
            break;
          case 4:
            _minPrice = 20000000;
            _maxPrice = null;
            break;
        }
      });
    });

    _categoryController.addListener(() {
      if (_categoryController.indexIsChanging) return;
      setState(() {
        switch (_categoryController.index) {
          case 0:
            _selectedCategory = null;
            break;
          case 1:
            _selectedCategory = PropertyType.commercial;
            break;
          case 2:
            _selectedCategory = PropertyType.residential;
            break;
          case 3:
            _selectedCategory = PropertyType.buy;
            break;
          case 4:
            _selectedCategory = PropertyType.rent;
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Explore Properties',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            // _buildPriceTabs(),
            _buildFilters(),
            Expanded(child: _buildPropertyGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search properties...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0.h),
        ),
        onChanged:
            (value) => setState(() => _searchText = value.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryBlock(
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          _buildCategoryBlock(
            label: 'Commercial',
            selected: _selectedCategory == PropertyType.commercial,
            onTap:
                () =>
                    setState(() => _selectedCategory = PropertyType.commercial),
          ),
          _buildCategoryBlock(
            label: 'Residential',
            selected: _selectedCategory == PropertyType.residential,
            onTap:
                () => setState(
                  () => _selectedCategory = PropertyType.residential,
                ),
          ),
          _buildCategoryBlock(
            label: 'Buy',
            selected: _selectedCategory == PropertyType.buy,
            onTap: () => setState(() => _selectedCategory = PropertyType.buy),
          ),
          _buildCategoryBlock(
            label: 'Rent',
            selected: _selectedCategory == PropertyType.rent,
            onTap: () => setState(() => _selectedCategory = PropertyType.rent),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBlock({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color borderColor = selected ? AppColors.primaryRed : Colors.grey;
    final Color textColor = selected ? AppColors.primaryRed : Colors.black87;
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: borderColor, width: 1.2.w),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildPriceTabs() {
  //   return Container(
  //     height: 50.h,
  //     margin: EdgeInsets.symmetric(vertical: 8.h),
  //     child: TabBar(
  //       controller: _priceController,
  //       isScrollable: true,
  //       labelColor: AppColors.primaryRed,
  //       unselectedLabelColor: Colors.black87,
  //       indicatorColor: AppColors.primaryRed,
  //       tabs: const [
  //         Tab(text: 'All Prices'),
  //         Tab(text: '5M-10M'),
  //         Tab(text: '10M-15M'),
  //         Tab(text: '15M-20M'),
  //         Tab(text: '20M+'),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFilters() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _showFilterDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 16.r, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          InkWell(
            onTap: _showSortDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.sort, size: 16.r, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Properties'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterSection('Bedrooms', _minBedrooms, _maxBedrooms, (
                    min,
                    max,
                  ) {
                    setState(() {
                      _minBedrooms = min;
                      _maxBedrooms = max;
                    });
                  }),
                  SizedBox(height: 16.h),
                  _buildFilterSection(
                    'Bathrooms',
                    _minBathrooms,
                    _maxBathrooms,
                    (min, max) {
                      setState(() {
                        _minBathrooms = min;
                        _maxBathrooms = max;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildAreaFilterSection(),
                  SizedBox(height: 16.h),
                  _buildStatusFilter(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _minBedrooms = null;
                    _maxBedrooms = null;
                    _minBathrooms = null;
                    _maxBathrooms = null;
                    _minArea = null;
                    _maxArea = null;
                    _selectedStatus = null;
                  });
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterSection(
    String title,
    int? min,
    int? max,
    Function(int?, int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intVal = int.tryParse(value);
                  onChanged(intVal, max);
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Max',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intVal = int.tryParse(value);
                  onChanged(min, intVal);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Area (sq ft)', style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Min',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final doubleVal = double.tryParse(value);
                  setState(() {
                    _minArea = doubleVal;
                  });
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Max',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final doubleVal = double.tryParse(value);
                  setState(() {
                    _maxArea = doubleVal;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children:
              PropertyStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                  selectedColor: AppColors.primaryRed.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryRed,
                );
              }).toList(),
        ),
      ],
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sort Properties'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption('Newest First', 'newest', Icons.access_time),
                _buildSortOption(
                  'Oldest First',
                  'oldest',
                  Icons.access_time_filled,
                ),
                _buildSortOption(
                  'Price: Low to High',
                  'price_low',
                  Icons.arrow_upward,
                ),
                _buildSortOption(
                  'Price: High to Low',
                  'price_high',
                  Icons.arrow_downward,
                ),
                _buildSortOption(
                  'Area: Small to Large',
                  'area_low',
                  Icons.arrow_upward,
                ),
                _buildSortOption(
                  'Area: Large to Small',
                  'area_high',
                  Icons.arrow_downward,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryRed : Colors.grey,
      ),
      title: Text(title),
      trailing:
          isSelected ? Icon(Icons.check, color: AppColors.primaryRed) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildPropertyGrid() {
    final List<Property> filteredProperties = _getFilteredProperties();

    if (filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.r, color: Colors.grey),
            SizedBox(height: 16.h),
            Text('No properties found', style: AppTextStyles.bodyMediumBold),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your search or filters',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      padding: EdgeInsets.all(6.w),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 6.w,
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        final property = filteredProperties[index];
        return PropertyCard(
          property: property,
          onTap: () => _showPropertyDetails(property),
          onFavorite: () => _toggleFavorite(property.id),
        );
      },
    );
  }

  List<Property> _getFilteredProperties() {
    List<Property> filtered =
        _properties.where((property) {
          final bool matchesSearch =
              _searchText.isEmpty ||
              property.title.toLowerCase().contains(_searchText) ||
              property.description.toLowerCase().contains(_searchText) ||
              property.location.toLowerCase().contains(_searchText);

          final bool matchesCategory =
              _selectedCategory == null || property.type == _selectedCategory;

          final bool matchesPrice =
              (_minPrice == null || property.price >= _minPrice!) &&
              (_maxPrice == null || property.price <= _maxPrice!);

          final bool matchesBedrooms =
              (_minBedrooms == null || property.bedrooms >= _minBedrooms!) &&
              (_maxBedrooms == null || property.bedrooms <= _maxBedrooms!);

          final bool matchesBathrooms =
              (_minBathrooms == null || property.bathrooms >= _minBathrooms!) &&
              (_maxBathrooms == null || property.bathrooms <= _maxBathrooms!);

          final bool matchesArea =
              (_minArea == null || property.area >= _minArea!) &&
              (_maxArea == null || property.area <= _maxArea!);

          final bool matchesStatus =
              _selectedStatus == null || property.status == _selectedStatus;

          return matchesSearch &&
              matchesCategory &&
              matchesPrice &&
              matchesBedrooms &&
              matchesBathrooms &&
              matchesArea &&
              matchesStatus;
        }).toList();

    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'area_low':
        filtered.sort((a, b) => a.area.compareTo(b.area));
        break;
      case 'area_high':
        filtered.sort((a, b) => b.area.compareTo(a.area));
        break;
    }

    return filtered;
  }

  void _showPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _toggleFavorite(String propertyId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite functionality coming soon')),
    );
  }
}
