import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'screens/job_application_form.dart';
import 'screens/ApplicationStatusPage.dart';
import 'screens/DocumentSubmissionPage.dart';
import 'screens/visa_status.dart';

class HomePage extends StatefulWidget {
  final String selfCallerID;
  const HomePage({Key? key, required this.selfCallerID}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentCarouselIndex = 0;
  final List<String> imageUrls = [
    'https://a.travel-assets.com/findyours-php/viewfinder/images/res70/542000/542607-singapore.jpg',
    'https://www.nccdp.org/wp-content/uploads/2024/03/elderly-asian-senior-woman-wheelchair-asian-careful-caregiver-nursing-home.jpg',
    'https://www.datocms-assets.com/32623/1729008596-singapore_skyline.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onBackgroundColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(onBackgroundColor),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 8),
                      _buildCarouselDots(),
                      const SizedBox(height: 24),
                      _buildQuickActionsSection(
                        context,
                        primaryColor,
                        onBackgroundColor,
                      ),
                      const SizedBox(height: 24),
                      _buildFeaturedJobsSection(
                        context,
                        onBackgroundColor,
                        primaryColor,
                      ),
                      const SizedBox(height: 24),
                      _buildBlogSection(onBackgroundColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color onBackgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              'Job Opportunities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onBackgroundColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: onBackgroundColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 192,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          autoPlay: true,
          onPageChanged: (index, reason) {
            setState(() {
              _currentCarouselIndex = index;
            });
          },
        ),
        items: imageUrls.map((url) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color.fromARGB(255, 200, 200, 200),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color.fromARGB(255, 200, 200, 200),
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  Container(
                    color: const Color.fromARGB(102, 0, 0, 0),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Nurses Wanted in Singapore',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Competitive salaries and benefits await.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCarouselDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageUrls.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentCarouselIndex == index ? 10 : 8,
          height: _currentCarouselIndex == index ? 10 : 8,
          decoration: BoxDecoration(
            color: _currentCarouselIndex == index ? Colors.green : Colors.grey[400],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }



  Widget _buildQuickActionsSection(
    BuildContext context,
    Color primaryColor,
    Color onBackgroundColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: onBackgroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicationStatusPage(),
                  ),
                );
              },
              child: _buildActionItem(
                icon: Icons.data_thresholding_outlined,
                label: 'Job Interview',
                primaryColor: primaryColor,
                onBackgroundColor: onBackgroundColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisaStatusPage(),
                  ),
                );
              },
              child: _buildActionItem(
                icon: Icons.flight_takeoff,
                label: 'Visa Status',
                primaryColor: primaryColor,
                onBackgroundColor: onBackgroundColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentSubmissionPage(),
                  ),
                );
              },
              child: _buildActionItem(
                icon: Icons.article_outlined,
                label: 'My Documents',
                primaryColor: primaryColor,
                onBackgroundColor: onBackgroundColor,
              ),
            ),
            _buildActionItem(
              icon: Icons.help_outline,
              label: 'Help',
              primaryColor: primaryColor,
              onBackgroundColor: onBackgroundColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color primaryColor,
    required Color onBackgroundColor,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color.fromARGB(
              51,
              (primaryColor.r * 255.0).round() & 0xff,
              (primaryColor.g * 255.0).round() & 0xff,
              (primaryColor.b * 255.0).round() & 0xff,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: onBackgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedJobsSection(
    BuildContext context,
    Color onBackgroundColor,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Jobs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: onBackgroundColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildJobCard(context, onBackgroundColor),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, Color onBackgroundColor) {
    final cardBackgroundColor = Colors.white;
    final secondaryTextColor = Colors.grey[600];
    final tertiaryTextColor = Colors.grey[500];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JobApplicationForm(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(51, 17, 147, 212),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                'https://www.nccdp.org/wp-content/uploads/2024/03/elderly-asian-senior-woman-wheelchair-asian-careful-caregiver-nursing-home.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live-in Caregiver',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: onBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Serene Care Home',
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: tertiaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        'Singapore',
                        style: TextStyle(fontSize: 14, color: tertiaryTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: tertiaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$2,000 / month',
                        style: TextStyle(fontSize: 14, color: tertiaryTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.bookmark_border, color: tertiaryTextColor),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection(Color onBackgroundColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Knowledge and Tips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: onBackgroundColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: onBackgroundColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBlogCard(
                onBackgroundColor: onBackgroundColor,
                imageUrl:
                    'https://www.datocms-assets.com/32623/1729008596-singapore_skyline.jpeg',
                title: 'How to Prepare for a Caregiver Interview',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBlogCard(
                onBackgroundColor: onBackgroundColor,
                imageUrl:
                    'https://www.qatarairways.com/content/dam/images/renditions/horizontal-hd/destinations/singapore/hd-singapore.jpg',
                title: 'Navigating Work Permits in Singapore',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlogCard({
    required Color onBackgroundColor,
    required String imageUrl,
    required String title,
  }) {
    final cardBackgroundColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: onBackgroundColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}
