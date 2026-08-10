import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/mock_data_service.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/services/wishlist_service.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:provider/provider.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  final List<ReelItem> _reels = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildMockReels();
  }

  void _buildMockReels() {
    // Build mock reels from products with "reel" style content
    final products = MockDataService.mockProducts;
    final reelUrls = [
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ];

    for (var i = 0; i < products.length; i++) {
      _reels.add(ReelItem(
        product: products[i],
        videoUrl: reelUrls[i % reelUrls.length],
        userName: 'Aisha Mehta',
        userAvatar: 'https://i.pravatar.cc/150?img=${47 + i}',
        caption: 'Wore this to a wedding 💕 #ootd #weddingguest',
        likes: 1200 + i * 234,
        comments: 45 + i * 12,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final reel in _reels) {
      reel.controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              return ReelView(
                reel: _reels[index],
                isActive: index == _pageController.hasClients
                    ? _pageController.page?.round() == index
                    : index == 0,
                onLike: () => _toggleLike(_reels[index]),
                onComment: () => _openComments(_reels[index]),
                onShare: () => _shareReel(_reels[index]),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text('Reels',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      )),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(FluentIcons.camera_24_regular, color: Colors.white),
                    onPressed: () => _createReel(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(ReelItem reel) {
    setState(() {
      reel.isLiked = !reel.isLiked;
      reel.likes += reel.isLiked ? 1 : -1;
    });
  }

  void _openComments(ReelItem reel) {
    // Show comments bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CommentsSheet(reel: reel),
    );
  }

  void _shareReel(ReelItem reel) {
    Share.share(
      'Check out "${reel.product.name}" on Dress — ${reel.caption}',
      subject: reel.product.name,
    );
  }

  void _createReel() {
    // Camera permission prompt; falls back to a clear message.
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.video_24_regular, color: AppTheme.textDark),
              title: Text('Record a reel', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              subtitle: Text('Open the camera and record up to 30s',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Camera reel recording is coming soon.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular, color: AppTheme.textDark),
              title: Text('Upload a reel', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              subtitle: Text('Pick a 15–30s vertical video from your gallery',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reel upload is coming soon.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReelItem {
  final Product product;
  final String videoUrl;
  final String userName;
  final String userAvatar;
  final String caption;
  int likes;
  final int comments;
  bool isLiked = false;
  VideoPlayerController? controller;
  bool isVideoReady = false;

  ReelItem({
    required this.product,
    required this.videoUrl,
    required this.userName,
    required this.userAvatar,
    required this.caption,
    required this.likes,
    required this.comments,
  });
}

class ReelView extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const ReelView({
    Key? key,
    required this.reel,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  }) : super(key: key);

  @override
  State<ReelView> createState() => _ReelViewState();
}

class _ReelViewState extends State<ReelView> {
  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    widget.reel.controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => widget.reel.isVideoReady = true);
          if (widget.isActive) {
            widget.reel.controller!.play();
            widget.reel.controller!.setLooping(true);
          }
        }
      });
  }

  @override
  void dispose() {
    widget.reel.controller?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel-${widget.reel.product.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          widget.reel.controller?.play();
        } else {
          widget.reel.controller?.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or fallback image
          if (widget.reel.isVideoReady && widget.reel.controller!.value.isInitialized)
            GestureDetector(
              onTap: () {
                if (widget.reel.controller!.value.isPlaying) {
                  widget.reel.controller!.pause();
                } else {
                  widget.reel.controller!.play();
                }
                setState(() {});
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.reel.controller!.value.aspectRatio,
                  child: VideoPlayer(widget.reel.controller!),
                ),
              ),
            )
          else
            // Fallback to product image while video loads
            CachedNetworkImage(
              imageUrl: widget.reel.product.images.isNotEmpty
                  ? widget.reel.product.images.first
                  : 'https://placehold.co/600x800',
              fit: BoxFit.cover,
            ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black87,
                ],
                stops: [0.5, 1.0],
              ),
            ),
          ),

          // Right side actions
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                _ReelAction(
                  icon: widget.reel.isLiked
                      ? FluentIcons.heart_24_filled
                      : FluentIcons.heart_24_regular,
                  color: widget.reel.isLiked ? Colors.red : Colors.white,
                  label: _formatCount(widget.reel.likes),
                  onTap: widget.onLike,
                ),
                const SizedBox(height: 24),
                _ReelAction(
                  icon: FluentIcons.chat_24_regular,
                  color: Colors.white,
                  label: '${widget.reel.comments}',
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 24),
                _ReelAction(
                  icon: FluentIcons.share_24_regular,
                  color: Colors.white,
                  label: 'Share',
                  onTap: widget.onShare,
                ),
                const SizedBox(height: 24),
                _ReelAction(
                  icon: FluentIcons.bookmark_24_regular,
                  color: Colors.white,
                  label: 'Save',
                  onTap: () async {
                    final userId = context.read<AppState>().currentUser.id;
                    await WishlistService().toggle(userId, widget.reel.product.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to wishlist')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Bottom: user info + caption + product tag
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: CachedNetworkImageProvider(widget.reel.userAvatar),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.reel.userName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You\'re now following ${widget.reel.userName}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Follow',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.reel.caption,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Product tag pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.box_24_regular, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.reel.product.name,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(
                        '₹ ${widget.reel.product.price.toStringAsFixed(0)}/day',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ReelAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final ReelItem reel;
  const _CommentsSheet({required this.reel});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentInput = TextEditingController();
  final List<Map<String, String>> _userComments = [];

  static const _demoComments = <Map<String, String>>[
    {'user': '@priya.s', 'text': 'Obsessed with this color 😍', 'time': '1h', 'avatar': 'https://i.pravatar.cc/150?img=5'},
    {'user': '@neha.r', 'text': 'Where is this from? Need!', 'time': '2h', 'avatar': 'https://i.pravatar.cc/150?img=6'},
    {'user': '@ananya.k', 'text': 'Looks so elegant on you ✨', 'time': '3h', 'avatar': 'https://i.pravatar.cc/150?img=7'},
    {'user': '@meera.t', 'text': 'Saving this for my engagement!', 'time': '5h', 'avatar': 'https://i.pravatar.cc/150?img=8'},
    {'user': '@kavya.m', 'text': 'Gorgeous! How much was the rental?', 'time': '6h', 'avatar': 'https://i.pravatar.cc/150?img=9'},
    {'user': '@isha.d', 'text': 'The drape is perfect 🙌', 'time': '8h', 'avatar': 'https://i.pravatar.cc/150?img=10'},
    {'user': '@tanya.p', 'text': 'Need this in my size ASAP', 'time': '12h', 'avatar': 'https://i.pravatar.cc/150?img=11'},
    {'user': '@divya.s', 'text': 'Wedding guest inspo 💯', 'time': '1d', 'avatar': 'https://i.pravatar.cc/150?img=12'},
  ];

  void _postComment() {
    final text = _commentInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _userComments.insert(0, {
        'user': '@you',
        'text': text,
        'time': 'now',
        'avatar': 'https://i.pravatar.cc/150?img=33',
      });
      _commentInput.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment posted'), duration: Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _commentInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('${widget.reel.comments} Comments',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _userComments.length + _demoComments.length,
                  itemBuilder: (context, i) {
                    final c = i < _userComments.length
                        ? _userComments[i]
                        : _demoComments[i - _userComments.length];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(c['avatar']!),
                      ),
                      title: Text(c['user']!,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text(c['text']!),
                      trailing: Text(c['time']!,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?img=33'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentInput,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _postComment(),
                      ),
                    ),
                    TextButton(
                      onPressed: _postComment,
                      child: Text('Post', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
