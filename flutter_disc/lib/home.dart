import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- SERVER DATA MODEL --- GLO1
// This class represents a Discord server or DM channel
// It stores all the information needed to display a server in the left sidebar and handle navigation
class Server {
  final String name;                    // The name of the server (e.g., 'Cassiopeia', 'Direct Messages')
  final Color avatarColor;              // The background color of the server's avatar/icon
  final IconData? icon;                 // Optional icon for DM or special servers (e.g., Icons.chat_bubble for DMs)
  final bool isDM;                      // Flag to identify if this is a Direct Messages server (true) or regular server (false)
  final List<ChannelCategory>? channels; // Optional list of channel categories that belong to this server

  const Server({
    required this.name,
    required this.avatarColor,
    this.icon,
    this.isDM = false,                  // By default, this is NOT a DM server
    this.channels,
  });
}

// --- CHANNEL DATA MODEL (for ServerChannelsPage) ---
// This class represents a category of channels within a server (e.g., "Text Channels", "Voice Channels")
class ChannelCategory {
  final String title;                   // The category name (e.g., 'Read', 'Activity', 'World')
  final bool isVoice;                   // Flag to indicate if this category contains voice channels (true) or text channels (false)
  final List<String> channelNames;      // A list of individual channel names in this category (e.g., ['greet', 'info', 'bye'])

  const ChannelCategory({
    required this.title,
    this.isVoice = false,               // By default, this is a text channel category
    required this.channelNames,
  });
}

// Data for all server icons in the rail (redefined to use the Server model)
// This list contains all the servers that appear in the left sidebar
// The order matters: DM always appears first, then regular servers
final List<Server> _allServers = [
  // DM Icon (Always first, handled as a special case)
  // This is the "Direct Messages" server that shows all your DMs
  const Server(name: 'Direct Messages', avatarColor: Color(0xFF5865F2), icon: Icons.chat_bubble, isDM: true),
  
  // Server 1: Cassiopeia (New Channel Data Added)
  // This server demonstrates the full channel structure with multiple categories and channels
  Server(
    name: 'Cassiopeia', 
    avatarColor: Colors.red,
    channels: [
      // Text channel category 1: "Read" - contains 3 text channels (greet, info, bye)
      const ChannelCategory(title: 'Read', isVoice: false, channelNames: ['greet', 'info', 'bye']),
      // Text channel category 2: "Activity" - contains 2 text channels (clips, bots)
      const ChannelCategory(title: 'Activity', isVoice: false, channelNames: ['clips', 'bots']),
      // Text channel category 3: "World" - contains 1 text channel (general)
      const ChannelCategory(title: 'World', isVoice: false, channelNames: ['general']),
      // Voice channel category: "World" - contains 2 voice channels (voice, music)
      const ChannelCategory(title: 'World', isVoice: true, channelNames: ['voice', 'music']),
    ],
  ),
  
  // Server 2: Work Hub
  // A simple server with just a name and avatar color (no channels defined yet)
  const Server(name: 'Work Hub', avatarColor: Colors.blueGrey), 
  
  // Server 3: Gaming
  // Another simple server with just a name and avatar color
  const Server(name: 'Gaming', avatarColor: Colors.teal), 
];

// --- MAIN DISCORD HOME WIDGET ---
// This is the main widget that builds the entire home screen with sidebar, content area, and bottom navigation
// It's a StatefulWidget because it needs to track which server is selected and which bottom nav tab is active
class DiscordHome extends StatefulWidget {
  const DiscordHome({super.key});

  @override
  State<DiscordHome> createState() => _DiscordHomeState();
}

class _DiscordHomeState extends State<DiscordHome> {
  // 0: DM/Home, 1: Notifications, 2: You (Bottom Nav Index)
  // This tracks which bottom navigation bar tab the user is currently viewing
  int _bottomNavIndex = 0; 
  
  // Tracks the currently selected server's data for the main content area
  // This is used to know which server's channels to display in the center panel
  Server? _selectedServer; 

  @override
  void initState() {
    super.initState();
    // Default to the Direct Messages server content on start
    // This finds the first server where isDM is true (which should be "Direct Messages")
    _selectedServer = _allServers.firstWhere((s) => s.isDM);
  }

  // This method handles when the user taps a bottom navigation bar item
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      // If we switch to Notifications (index 1) or Profile (index 2), clear the server selection
      // This ensures we don't show server channels when viewing those pages
      if (index != 0) {
        _selectedServer = null;
      } else {
        // If switching back to Home (index 0), reset to DM list
        _selectedServer = _allServers.firstWhere((s) => s.isDM);
      }
    });
  }
  
  // Callback function passed to ServerRail to handle server icon clicks
  void _onServerSelected(Server server) {
    setState(() {
      // If a DM server is selected, we show the MessagesPage
      if (server.isDM) {
        _selectedServer = _allServers.firstWhere((s) => s.isDM);
      } else {
        // If a regular server is selected, we show the ServerChannelsPage with all its channels
        _selectedServer = server;
      }
      // Ensure the 'Home' tab (index 0) is active when viewing DMs or Channels
      // This prevents showing Notifications or Profile page while viewing a server
      _bottomNavIndex = 0;
    });
  }

  // This method determines which page content to display based on the current state
  // It returns the appropriate Widget (MessagesPage, NotificationsPage, ProfilePage, or ServerChannelsPage)
  Widget _getContentPage() {
    if (_bottomNavIndex == 1) {
      // User is on the Notifications tab
      return const NotificationsPage();
    } else if (_bottomNavIndex == 2) {
      // User is on the Profile/You tab
      return const ProfilePage();
    } else if (_selectedServer != null && !_selectedServer!.isDM) {
      // Show Channel list for a specific server (e.g., Cassiopeia)
      // The exclamation mark (!) asserts that _selectedServer is not null
      return ServerChannelsPage(server: _selectedServer!);
    } else {
      // Default to Direct Messages page (Home/DM View)
      return const MessagesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show left panel when on Home tab (bottom nav index 0)
    // This hides the server rail when viewing Notifications or Profile
    final bool showLeftPanel = _bottomNavIndex == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F22), // Discord dark background color
      body: SafeArea(
        child: Row(
          children: [
            // 1. Left Server Rail (only visible on Home tab)
            // This displays the column of server icons on the left side of the app
            if (showLeftPanel)
              ServerRail(
                servers: _allServers,
                onServerSelected: _onServerSelected, // Callback when user taps a server
                selectedServerName: _selectedServer?.name,
              ),
            
            // 2. Main Content Area
            // This expands to fill the remaining space and shows either:
            // - DM list (MessagesPage)
            // - Server channels (ServerChannelsPage)
            // - Notifications (NotificationsPage)
            // - Profile (ProfilePage)
            Expanded(
              child: _getContentPage(),
            ),
          ],
        ),
      ),
      
      // 3. Persistent Bottom Navigation Bar
      // Always visible and allows switching between Home, Notifications, and Profile tabs
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1F22), // Match the main background
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure icons stay fixed without shifting
        selectedItemColor: Colors.white, // Color when tab is selected
        unselectedItemColor: Colors.white54, // Color when tab is not selected
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10),
        items: [
          // Home Tab
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.forum_rounded, size: 28),
                // Blue dot indicator - shows when Home tab is selected
                if (_bottomNavIndex == 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5865F2), // Discord blue color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Home',
          ),
          
          // Notifications Tab
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded, size: 28),
            label: 'Notifications',
          ),
          
          // You Tab (Profile)
          BottomNavigationBarItem(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                // This is a placeholder for the user's avatar in the bottom nav
                color: Colors.redAccent, 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _bottomNavIndex == 2 ? Colors.white : Colors.transparent,
                  width: 2, // Shows white border when Profile tab is selected
                ),
                // Placeholder image for the user's avatar
                image: const DecorationImage(
                  image: NetworkImage('https://placehold.co/30x30/FF69B4/FFFFFF?text=P'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'You',
          ),
        ],
      ),
    );
  }
} // GLO1

// --- 1. SERVER RAIL WIDGET (Left Side) --- //GLO2
// This widget displays the vertical column of server icons on the left side of the screen
// It's only shown when the user is on the Home tab
class ServerRail extends StatelessWidget {
  final List<Server> servers;              // List of all servers to display as icons
  final ValueChanged<Server> onServerSelected; // Callback when user taps a server icon
  final String? selectedServerName;        // Name of currently selected server (used to highlight it)

  const ServerRail({
    super.key,
    required this.servers,
    required this.onServerSelected,
    this.selectedServerName,
  });

  // Additional static icon entries that aren't content pages
  // These are special buttons that always appear at the bottom of the server rail
  final List<Map<String, dynamic>> _controlIcons = const [
    {'icon': Icons.add, 'color': Color(0xFF3B9E78), 'name': 'Add a Server'},
    {'icon': Icons.explore_rounded, 'color': Color(0xFF3B9E78), 'name': 'Discover'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72, // Standard Discord server rail width
      color: const Color(0xFF232428), // Slightly lighter gray than the main background
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Map through each server and create a ServerIcon widget for it
          ...servers.map((server) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ServerIcon(
              server: server,
              // Check if the server is the selected one (handling DM as a special case if no other server is selected)
              isSelected: server.name == selectedServerName,
              onTap: () => onServerSelected(server), // Call callback when user taps this server icon
            ),
          )).toList(),
          
          // Divider line separating server icons from control icons
          const Divider(color: Colors.white12, indent: 16, endIndent: 16),

          // Map through control icons (Add Server, Discover) and create ServerIcon widgets for them
          ..._controlIcons.map((control) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ServerIcon(
              // Placeholder server object for control icons
              server: Server(name: control['name'], avatarColor: control['color'], icon: control['icon']),
              isControl: true, // Marker for non-content button (doesn't open a page)
              onTap: () {
                // Handle control buttons (Add, Discover)
                if (control['icon'] == Icons.add) {
                  // Navigate to the CreateServerPage full screen when 'Add' is clicked
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateServerPage(),
                    ),
                  );
                } else {
                  // No SnackBar/Alert for Discover, just visual feedback from InkWell
                }
              },
            ),
          )).toList(),
        ],
      ),
    );
  }
} // GLO2

// --- Server Icon Component --- GLO3
// This widget displays a single server icon in the left rail
// It shows different shapes and styles based on whether it's selected or what type of server it is
class ServerIcon extends StatelessWidget {
  final Server server;                    // The server data to display
  final bool isSelected;                  // Whether this server is currently selected
  final VoidCallback onTap;               // Callback when user taps this icon
  final bool isControl;                   // True for 'Add Server' or 'Discover' buttons

  const ServerIcon({
    super.key,
    required this.server,
    this.isSelected = false,
    required this.onTap,
    this.isControl = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the shape and size of the server icon based on its type
    double size = 48.0;
    BorderRadius borderRadius;

    if (server.icon == Icons.chat_bubble) {
      // DM icon is always a rounded square (more rounded)
      borderRadius = BorderRadius.circular(15);
    } else if (isControl) {
      // Add/Explore buttons are always circles (perfect circles for buttons)
      borderRadius = BorderRadius.circular(size / 2);
    } else {
      // REGULAR SERVER ICON: Rounded square when unselected, tighter rounded square when selected
      // Selected servers appear more "squared" (less rounded) to indicate selection
      borderRadius = BorderRadius.circular(isSelected ? 10 : 15);
    }

    // Server Rail Indicator - the white bar on the left when a server is selected
    Widget indicator = Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 8.0 : 0.0, // Width becomes 8 when selected, 0 when not
        // Margin creates space at top and bottom when selected, centers when not
        margin: EdgeInsets.only(top: isSelected ? 8.0 : 16.0, bottom: isSelected ? 8.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    return Tooltip( 
      message: server.name, // menampilkan nama server saat hover
      preferBelow: false,
      verticalOffset: -20,
      textStyle: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: onTap, // ikon bisa di klik
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Left indicator bar (shown when server is selected)
            indicator,
            Center(
              child: AnimatedContainer( //membuat animasi sederhana
                duration: const Duration(milliseconds: 300),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: server.avatarColor,
                  borderRadius: borderRadius, // Use corrected radius based on server type
                ),
                child: server.icon != null
                    // If server has an icon, display it (used for DM and control buttons)
                    ? Icon(server.icon, color: Colors.white, size: 30)
                    // If no icon, display the first letter of the server name
                    : Center(
                        child: Text(
                          server.name.substring(0, 1), // First letter of server name
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} //GLO3

// --- 2. PAGE VIEWS (Content Area) --- GLO4

// --- 2.1 Messages Page (Home/DM View) ---
// This page displays the list of Direct Messages and allows users to start new conversations
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2F3136), // Discord Chat Background (slightly lighter than main background)
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Title, Search Icon, and Add Friends Icon)
          Row(
            children: [
              // Title: "Direct Messages"
              Text(
                'Direct Messages', 
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(), // Pushes the icons to the far right
              
              // Search Icon - allows user to search through DMs
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {}, // No SnackBar/Alert
              ),
              // Add Friends Icon - allows user to add new friends
              IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
                onPressed: () {}, // No SnackBar/Alert
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Full-width Search Input - for jumping to or searching DMs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              style: GoogleFonts.montserrat(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search or Jump to...',
                hintStyle: GoogleFonts.montserrat(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // DM List - Scrollable list of all direct messages
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Each DMListItem represents a conversation or DM group
                DMListItem(
                  name: 'merr', 
                  lastMessage: 'merr: https://discord.gg/Kwwu6UdGU', 
                  time: '10d',  // 10 days ago
                  avatarColor: Colors.purple,
                ),
                DMListItem(
                  name: 'Farm Merge Valley', 
                  lastMessage: 'Farm Merge Valley: Vee visited your farm, merr! :disc...', 
                  time: '14d', // 14 days ago
                  avatarColor: Colors.orange,
                  isServer: true, // This is a server notification, not a direct message
                ),
                DMListItem(
                  name: 'Discord', 
                  lastMessage: 'Discord: Hello, Discord has updated all of its accounts t...', 
                  time: '1y', // 1 year ago
                  avatarColor: const Color(0xFF5865F2),
                  isOfficial: true, // Official Discord account (shows blue checkmark)
                ),
                DMListItem(
                  name: 'Koya', 
                  lastMessage: 'Koya: Cassiopeia', 
                  time: '3y', // 3 years ago
                  avatarColor: Colors.brown,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Floating New Message Button (Bottom Right)
          // Allows user to start a new conversation
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: const Color(0xFF5865F2), // Discord blue
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add_comment_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DM List Item Component (Navigates to Chat) ---
// This widget represents a single DM conversation in the list
// When tapped, it navigates to the chat screen for that conversation
class DMListItem extends StatelessWidget {
  final String name;                      // Name of the person or group
  final String lastMessage;               // Preview of the most recent message
  final String time;                      // Time since last message (e.g., "10d", "1y")
  final Color avatarColor;                // Background color for the avatar
  final bool isServer;                    // Whether this is a server notification (uses square avatar) or DM (uses round avatar)
  final bool isOfficial;                  // Whether this is an official Discord account (shows icon + checkmark)

  const DMListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarColor,
    this.isServer = false,
    this.isOfficial = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      
      // Avatar - the colored circle/square on the left
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: avatarColor,
          // Rounded square for servers, circle for direct messages
          borderRadius: BorderRadius.circular(isServer ? 15 : 25),
        ),
        // Display icon or placeholder
        child: isOfficial 
            ? const Icon(Icons.discord, color: Colors.white, size: 30) // Official Discord icon
            : const Icon(Icons.person, color: Colors.white, size: 30),  // Generic person icon
      ),
      
      // Title - The name with optional verification badge
      title: Row(
        children: [
          Text(
            name,
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          // Blue verified checkmark for official accounts
          if (isOfficial)
            const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.verified, color: Color(0xFF5865F2), size: 16),
            ),
        ],
      ),
      
      // Subtitle - Preview of the last message
      subtitle: Text(
        lastMessage,
        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
        overflow: TextOverflow.ellipsis, // Truncate with "..." if message is too long
      ),
      
      // Trailing - Time indicator showing when the message was received
      trailing: Text(
        time,
        style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
      ),
      
      // onTap - Navigate to the chat screen when user taps this conversation
      onTap: () {
        // --- Navigation to chat screen implemented here ---
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChannelPage(
              channelName: name, 
              isDM: true,                         // This is a DM conversation, not a server channel
              avatarColor: avatarColor,
            ),
          ),
        );
      },
    );
  }
} // GLO4


// --- 2.2 Notifications Page --- SHELLY1
// This page displays notifications about server events, friend requests, etc.
// Currently shows a placeholder "Nothing here yet" message
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2F3136), // Dark background matching other pages
      child: Column(
        children: [
          // Header Bar with title and menu button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // More options button (currently no functionality)
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
                  onPressed: () {}, // No SnackBar/Alert
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          
          // Main Content with Image Asset
          // Shows an empty state since there are no notifications
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative image
                  Image.asset(
                    'assets/discord_notif.png', // Replace with your image filename
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nothing here yet',
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Helpful subtitle explaining when notifications appear
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Come back for notifications on events, streams and more.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 80), // Padding from the bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // SHELLY1

// --- 2.3 Profile Page (You Tab) --- // MICHAEL1
// This page displays the user's profile information, settings, and options
// Uses CustomScrollView with SliverAppBar for a nice scrolling effect
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3136), // Dark background
      body: CustomScrollView(
        slivers: [
          // SliverAppBar - sticky header at the top
          SliverAppBar(
            backgroundColor: const Color(0xFF2F3136),
            automaticallyImplyLeading: false,
            pinned: true,           // Stays at top when scrolling
            expandedHeight: 0,       // No initial expansion
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Home/Store Icon
                  IconButton(
                    icon: const Icon(Icons.storefront_outlined, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                  // Nitro Icon/Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1F22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/nitro_icon.jpg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  // Settings Icon - navigates to SettingsPage
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Main scrollable content
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Profile Header / Avatar Section ---
                      // Shows username and tag (username #number)
                      const _ProfileHeader(
                        username: 'Merrrrrrr',
                        tag: 'merr7732',
                      ),
                      const SizedBox(height: 20),

                      // --- Edit Profile Button ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {}, // **No onPressed functionality set**
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: Text(
                            'Edit Profile',
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5865F2), // Discord blue
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Amp up your profile (Nitro/Shop Card) ---
                      // Promotional card encouraging user to get Nitro
                      const _NitroShopCard(),
                      const SizedBox(height: 24),

                      // --- Member Since Detail Card ---
                      // Shows when the user joined Discord
                      const _ProfileDetailCard(
                        title: 'Member Since',
                        content: '12 Oct 2022',
                        icon: Icons.discord,
                        iconColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      
                      // --- Friends Card (Custom Image) ---
                      // Allows viewing friends list
                      _ProfileDetailCard(
                        title: 'Friends',
                        content: '',
                        icon: Icons.person,
                        iconColor: Colors.white,
                        showTrailing: true,
                        trailingWidget: Row(
                          children: [
                            // Custom Image from user upload
                            ClipOval(
                              child: Image.asset(
                                'assets/discord_logo.png', // **Using assumed asset path**
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- Note Text Field ---
                      // Allows user to write personal notes (only visible to them)
                      const _ProfileDetailCard(
                        title: 'Note (only visible to you)',
                        content: '', // Empty content as it uses a TextField now
                        icon: Icons.note_alt_outlined,
                        iconColor: Colors.white,
                        showTrailing: true,
                        trailingWidget: SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Write a note about this user',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
} // MICHAEL1

// --- NitroSubscriptionPage --- MICHAEL 2
// This page displays Discord Nitro subscription options (pricing, features, etc.)
// Shows both regular Nitro and Nitro Basic plans
class NitroSubscriptionPage extends StatelessWidget {
  const NitroSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color discordDark = Color(0xFF1E1F22);     // Main dark background
    const Color cardBackground = Color(0xFF232428);  // Card background color
    const Color nitroPurple = Color(0xFF5865F2);     // Primary Discord blue
    const Color nitroPink = Color(0xFFFF73FA);       // Accent pink for premium Nitro
    
    // Helper Widget for the Nitro feature list
    // Creates a row with an icon and text for each feature
    Widget _buildFeatureRow(IconData icon, String text, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      );
    }

    // Helper Widget for the full Nitro Card
    // Reusable card that displays a Nitro subscription plan with features and pricing
    Widget _buildNitroCard({
      required String title,
      required String price,
      required List<Widget> features,
      required Color accentColor,
      required String buttonText,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Title and Price)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                Text(
                  price,
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Image Placeholder (colored box with icon in top right corner)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 80,
                width: 120,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.rocket_launch, color: accentColor, size: 40),
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Feature List
            ...features,

            const SizedBox(height: 24),
            
            // Get Nitro Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: nitroPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: discordDark,
      appBar: AppBar(
        backgroundColor: discordDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Discord NITRO',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title Tagline
            Text(
              'Unleash more fun on Discord',
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            // --- FULL NITRO CARD ---
            _buildNitroCard(
              title: 'NITRO',
              price: 'IDR 85,000.00 / month',
              accentColor: nitroPink,
              buttonText: 'Get Nitro',
              features: [
                _buildFeatureRow(Icons.upload_file, '500 MB uploads', Colors.white),
                _buildFeatureRow(Icons.tag_faces, 'Custom emojis anywhere', Colors.white),
                _buildFeatureRow(Icons.star, 'Unlimited Super Reactions', Colors.white),
                _buildFeatureRow(Icons.videocam, 'HD video streaming', Colors.white),
                _buildFeatureRow(Icons.offline_bolt, '2 Server Boosts', Colors.white),
                _buildFeatureRow(Icons.person, 'Custom profiles and more!', Colors.white),
              ],
            ),
            
            const SizedBox(height: 20),

            // --- NITRO BASIC CARD ---
            _buildNitroCard(
              title: 'NITRO BASIC',
              price: 'IDR 29,000.00 / month',
              accentColor: Colors.blueAccent, // Use blue for basic card distinction
              buttonText: 'Get Basic',
              features: [
                _buildFeatureRow(Icons.upload_file, '50 MB uploads', Colors.white),
                _buildFeatureRow(Icons.tag_faces, 'Custom emojis anywhere', Colors.white),
                _buildFeatureRow(Icons.badge, 'Special Nitro badge on your profile', Colors.white),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
} // MICHAEL2

class SettingsPage extends StatelessWidget { // SHELLY2
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Discord Dark Theme Colors
    const Color discordBackground = Color(0xFF1E1F22); // Main dark background
    const Color discordAccent = Color(0xFF2F3136);    // Slightly lighter background for list items
    const Color textPrimary = Colors.white;           // Primary text color
    const Color textSecondary = Colors.white54;       // Secondary text color (dimmer)
    const Color nitroPink = Color(0xFFFF73FA);        // Accent pink color
    
    // Helper function to create section header text (e.g., "ACCOUNT SETTINGS", "APP SETTINGS")
    Widget _buildHeader(String title) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
        child: Text(
          title,
          style: GoogleFonts.montserrat(color: textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: discordBackground, // Main background
      body: CustomScrollView(
        slivers: [
          // --- App Bar (Header) ---
          SliverAppBar(
            backgroundColor: discordBackground, // App bar matches main background
            elevation: 0, 
            pinned: true,           // Header stays at top when scrolling
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: textPrimary, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.montserrat(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
          
          // --- Main Content List (Scrollable) ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: discordAccent, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: textSecondary),
                        prefixIcon: Icon(Icons.search, color: textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 10.0, left: 0), 
                      ),
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                ),

                // --- ACCOUNT SETTINGS SECTION ---
                _buildHeader('ACCOUNT SETTINGS'),
                // Nitro option with custom image
                _FullWidthSettingsListItem(
                  title: 'Get Nitro',
                  leadingWidget: Image.asset(
                    'assets/nitro_icon.jpg',
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NitroSubscriptionPage()),
                    );
                  },
                ),
                // Account settings option
                _FullWidthSettingsListItem(
                  title: 'Account', icon: Icons.person, iconColor: Colors.white, onTap: () {},
                ),
                // Content & Social settings
                _FullWidthSettingsListItem(
                  title: 'Content & Social', icon: Icons.people_alt_rounded, iconColor: Colors.white, onTap: () {},
                ),
                // Data & Privacy settings
                _FullWidthSettingsListItem(
                  title: 'Data & Privacy', icon: Icons.lock, iconColor: Colors.white, onTap: () {},
                ),
                // Family Centre option
                _FullWidthSettingsListItem(
                  title: 'Family Centre', icon: Icons.family_restroom, iconColor: Colors.white, onTap: () {},
                ),
                // Authorized Apps option
                _FullWidthSettingsListItem(
                  title: 'Authorised Apps', icon: Icons.vpn_key, iconColor: Colors.white, onTap: () {},
                ),
                // Devices option
                _FullWidthSettingsListItem(
                  title: 'Devices', icon: Icons.devices, iconColor: Colors.white, onTap: () {},
                ),
                // Connections option (for connecting social media, etc.)
                _FullWidthSettingsListItem(
                  title: 'Connections', icon: Icons.cloud_queue, iconColor: Colors.white, onTap: () {},
                ),
                // Clips option
                _FullWidthSettingsListItem(
                  title: 'Clips', icon: Icons.movie, iconColor: Colors.white, onTap: () {},
                ),
                // Scan QR Code option
                _FullWidthSettingsListItem(
                  title: 'Scan QR Code', icon: Icons.qr_code_scanner, iconColor: Colors.white, onTap: () {},
                ),
                
                // --- PAYMENT SETTINGS SECTION ---
                _buildHeader('PAYMENT SETTINGS'),
                // Discord Shop option
                _FullWidthSettingsListItem(
                  title: 'Shop', icon: Icons.store, iconColor: Colors.white, onTap: () {},
                ),
                // Quests option
                _FullWidthSettingsListItem(
                  title: 'Quests', icon: Icons.workspace_premium, iconColor: Colors.white, onTap: () {},
                ),
                // Server Boost option
                _FullWidthSettingsListItem(
                  title: 'Server Boost', icon: Icons.hexagon_outlined, iconColor: Colors.white, onTap: () {},
                ),
                // Nitro Gifting option
                _FullWidthSettingsListItem(
                  title: 'Nitro Gifting', icon: Icons.card_giftcard, iconColor: Colors.white, onTap: () {},
                ),
                // Restore App Store Subscriptions option
                _FullWidthSettingsListItem(
                  title: 'Restore App Store Subscriptions', icon: Icons.remove_red_eye_outlined, iconColor: Colors.white, onTap: () {},
                ),

                // --- APP SETTINGS SECTION ---
                _buildHeader('APP SETTINGS'),
                // Voice settings
                _FullWidthSettingsListItem(
                  title: 'Voice', icon: Icons.mic, iconColor: Colors.white, subtitle: 'Voice Activity', onTap: () {},
                ),
                // Appearance/Theme settings
                _FullWidthSettingsListItem(
                  title: 'Appearance', icon: Icons.palette, iconColor: Colors.white, subtitle: 'Dark', onTap: () {},
                ),
                // Accessibility settings
                _FullWidthSettingsListItem(
                  title: 'Accessibility', icon: Icons.accessibility, iconColor: Colors.white, onTap: () {},
                ),
                // Language settings
                _FullWidthSettingsListItem(
                  title: 'Language', icon: Icons.translate, iconColor: Colors.white, subtitle: 'English, UK', onTap: () {},
                ),
                // Chat settings
                _FullWidthSettingsListItem(
                  title: 'Chat', icon: Icons.chat, iconColor: Colors.white, onTap: () {},
                ),
                // Web Browser settings
                _FullWidthSettingsListItem(
                  title: 'Web Browser', icon: Icons.language, iconColor: Colors.white, onTap: () {},
                ),

                // --- End Padding ---
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for a single, full-width settings list item (with optional subtitle)
// Used extensively in SettingsPage to create each menu item with icon, title, and optional subtitle
class _FullWidthSettingsListItem extends StatelessWidget {
  final String title;                     // Main text of the menu item
  final String? subtitle;                 // Optional secondary text (e.g., current value like "Dark" for appearance)
  final IconData? icon;                   // Optional icon (made nullable to support custom widgets)
  final Color? iconColor;                 // Color of the icon
  final Widget? leadingWidget;            // Alternative to icon - allows custom widgets like Image.asset
  final VoidCallback onTap;               // Callback when user taps this item

  const _FullWidthSettingsListItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.leadingWidget,
    required this.onTap,
  }) : assert(icon != null || leadingWidget != null, 'Either icon or leadingWidget must be provided.'); // Ensures one is provided

  @override
  Widget build(BuildContext context) {
    // Determine the leading widget: use leadingWidget if provided, else use the Icon
    // This allows flexibility in showing either icons or custom images
    final Widget effectiveLeading = leadingWidget ?? Icon(icon, color: iconColor, size: 24);

    return Container(
      color: const Color(0xFF2F3136), // Use discordAccent for list item background
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        tileColor: Colors.transparent, 
        
        leading: effectiveLeading, // The icon or custom widget
        
        title: Text(
          title,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        
        // Conditional Trailing - shows subtitle and arrow icon if trailing is enabled
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show subtitle (current value) if provided
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  subtitle!,
                  style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14),
                ),
              ),
            // Arrow icon pointing right
            const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
} // SHELLY2

// Sub-widget: Profile Header (Avatar and Name) // MICHAEL3
// Displays the user's profile picture, username, and Discord tag
class _ProfileHeader extends StatelessWidget {
  final String username;      // The user's display name
  final String tag;           // The user's Discord tag (like "merr7732")

  const _ProfileHeader({required this.username, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder for Avatar - a circular profile picture
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blueGrey, // Placeholder color
            borderRadius: BorderRadius.circular(40), // Perfect circle
            border: Border.all(color: const Color(0xFF2F3136), width: 6), // Border for separation
          ),
        ),
        const SizedBox(height: 10),
        
        // Display the username
        Text(
          username,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        
        // Display the Discord tag (with # prefix)
        Text(
          '#$tag',
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
} // MICHAEL3

// Sub-widget: Nitro/Shop Card
// Promotional card that encourages users to get Nitro or visit the shop
class _NitroShopCard extends StatelessWidget { // MICHAEL4
  const _NitroShopCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232428), // Dark card background
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amp up your profile',
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Close button to dismiss this card
              const Icon(Icons.close, color: Colors.white54, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // "Get Nitro" button
              Expanded(
                child: _CardButton(
                  title: 'Get Nitro',
                  iconWidget: Image.asset(
                    'assets/nitro_icon.jpg', // Custom image for Nitro
                    height: 32, 
                    width: 32,
                  ),
                  onPressed: () {
                    // Navigate to Nitro subscription page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NitroSubscriptionPage()),
                    );
                  }
                ),
              ),
              const SizedBox(width: 12),
              // "Shop" button
              Expanded(
                child: _CardButton(
                  title: 'Shop',
                  icon: Icons.store_rounded,
                  iconColor: Colors.lightGreen,
                  onPressed: () {}, // **No onPressed functionality set**
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} // MICHAEL4

// Sub-widget: Small button inside Nitro/Shop Card
// Reusable button component for the Nitro card showing icon and text
class _CardButton extends StatelessWidget { // MICHAEL5
  final String title;                     // Button label text
  final IconData? icon;                   // Optional Material icon
  final Color? iconColor;                 // Color of the Material icon
  final Widget? iconWidget;               // Alternative to icon - for custom widgets like Image
  final VoidCallback onPressed;           // Callback when button is pressed

  const _CardButton({
    required this.title,
    this.icon,
    this.iconColor,
    this.iconWidget,
    required this.onPressed,
  }) : assert(icon != null || iconWidget != null, 'Either icon or iconWidget must be provided.');

  @override
  Widget build(BuildContext context) {
    // Determine the effective icon widget, placed in a consistent SizedBox
    final Widget effectiveIcon = SizedBox(
      height: 32,
      width: 32,
      child: Center(
        child: iconWidget ?? Icon(icon, color: iconColor, size: 32),
      ),
    );

    return InkWell( // Use InkWell for better button visuals and ripple effect
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF40444B), // Gray background
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            effectiveIcon, // Display the icon
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} // MICHAEL5

// Sub-widget: Profile Detail Card
// Used to display various profile information (Member Since, Friends, Note)
class _ProfileDetailCard extends StatelessWidget { // MICHAEL6
  final String title;                     // Card title (e.g., "Member Since")
  final String content;                   // Main content text
  final IconData icon;                    // Icon to display on the left
  final Color iconColor;                  // Color of the icon
  final bool showTrailing;                // Whether to show custom trailing widget
  final Widget? trailingWidget;           // Custom widget on the right (e.g., TextField, image)

  const _ProfileDetailCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
    this.showTrailing = false,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232428), // Dark card background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Content row with main text and optional trailing widget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  content,
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
                ),
              ),
              // Show trailing widget if enabled
              if (showTrailing && trailingWidget != null) trailingWidget!,
            ],
          ),
        ],
      ),
    );
  }
} // MICHAEL6

// --- NEW WIDGET: SERVER CHANNELS PAGE (Channel List) --- GLO5
// This page displays all channels and categories for a selected server
// Shows text channels (#channel), voice channels (mic icon), and special options like Boost Goal
class ServerChannelsPage extends StatelessWidget {
  final Server server;  // The server whose channels we're displaying
  
  const ServerChannelsPage({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    // Determine the color for the channel list background (slightly lighter than main background)
    final Color channelRailColor = const Color(0xFF232428); 
    
    return Container(
      color: channelRailColor, // Background color for the channel list pane
      child: Column(
        children: [
          // Header Bar (Server Name & Dropdown)
          // Displays the server name and allows users to see more options
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2F3136), // Header color (slightly lighter)
              border: Border(bottom: BorderSide(color: Color(0xFF1E1F22), width: 1)), // Bottom border
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Server name
                Expanded(
                  child: Text(
                    server.name,
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Dropdown icon for additional options
                const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 24),
              ],
            ),
          ),
          
          // List of Channels and Categories
          // Scrollable list of all channels organized by categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
              children: [
                // Static options that appear above channel categories
                // Placeholder: Boost Goal - shows server boost progress
                const _ChannelOption(
                  icon: Icons.offline_bolt_rounded,
                  title: 'Boost Goal',
                  subtitle: '0/28 Boosts',
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  showSubtitle: true,
                ),
                
                // Placeholder: Events - shows server events
                const _ChannelOption(
                  icon: Icons.calendar_today_rounded,
                  title: 'Events',
                ),
                
                // Placeholder: Server Boosts - manage boosters
                const _ChannelOption(
                  icon: Icons.emoji_events_rounded,
                  title: 'Server Boosts',
                ),
                
                // Divider separating static options from channel categories
                const Divider(color: Colors.white12, height: 20, indent: 8, endIndent: 8),
                
                // Actual Channel Categories
                // Loops through each category in the server and displays it
                if (server.channels != null)
                  ...server.channels!.map((category) => _ChannelCategoryWidget(category: category)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // GLO5

// Sub-widget for displaying a channel list category (e.g., "TEXT CHANNELS", "VOICE CHANNELS")
// Shows a category header and all channels within that category
class _ChannelCategoryWidget extends StatelessWidget { // GLO6
  final ChannelCategory category;  // The category to display

  const _ChannelCategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Title with dropdown arrow (e.g., "READ ▼")
              Text(
                '${category.title.toUpperCase()} \u{25be}', // \u{25be} is the down arrow character
                style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              // Plus icon to add a new channel to this category
              const Icon(Icons.add, color: Colors.white54, size: 18),
            ],
          ),
        ),
        
        // List of Channels within the Category
        // Maps each channel name to a _ChannelListItem widget
        ...category.channelNames.map((channelName) => _ChannelListItem(
          name: channelName,
          isVoice: category.isVoice, // Pass whether this is a voice or text category
        )).toList(),
        
        const SizedBox(height: 12), // Space before next category
      ],
    );
  }
} // GLO6

// Sub-widget for a single text or voice channel
// Displays a channel in the channel list, with different icons for text (#) vs voice (mic)
class _ChannelListItem extends StatelessWidget { // GLO7
  final String name;              // The channel name (e.g., "greet", "general")
  final bool isVoice;             // Whether this is a voice channel (true) or text channel (false)
  
  const _ChannelListItem({required this.name, this.isVoice = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the chat page for this channel/server
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChannelPage(
              channelName: '#$name', 
              isDM: false, // This is a server channel, not a DM
              avatarColor: const Color(0xFF5865F2),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          // Highlight background if this is the selected channel (greet is selected by default)
          color: name == 'greet' ? const Color(0xFF393B41) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            // Icon showing if this is a text (#) or voice (mic) channel
            Icon(
              isVoice ? Icons.volume_up_rounded : Icons.numbers_outlined,
              color: name == 'greet' ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            
            // Channel name
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.montserrat(
                  color: name == 'greet' ? Colors.white : Colors.white70,
                  fontWeight: name == 'greet' ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Placeholder action icons (only show if this channel is selected/hovered)
            if (name == 'greet')
              const Row(
                children: [
                  // User count icon
                  Icon(Icons.person, color: Colors.white70, size: 18),
                  SizedBox(width: 4),
                  // Settings icon for channel options
                  Icon(Icons.settings, color: Colors.white70, size: 18),
                ],
              ),
          ],
        ),
      ),
    );
  }
} // GLO7

// Sub-widget for static options in the channel rail (Boost Goal, Events)
// Displays special channel options that aren't actual channels but interactive elements
class _ChannelOption extends StatelessWidget { // GLO8
  final IconData icon;                    // Icon for this option
  final String title;                     // Title text
  final String? subtitle;                 // Optional subtitle (e.g., "0/28 Boosts")
  final IconData? trailingIcon;           // Optional trailing icon (e.g., arrow)
  final bool showSubtitle;                // Whether to display the subtitle

  const _ChannelOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingIcon,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // No SnackBar/Alert
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            // Icon on the left
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 12),
            
            // Title and optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main title text
                  Text(
                    title,
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  // Optional subtitle (e.g., boost progress)
                  if (showSubtitle && subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 13),
                    ),
                ],
              ),
            ),
            
            // Optional trailing icon (usually an arrow)
            if (trailingIcon != null)
              Icon(trailingIcon, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
} // GLO8

// --- 3. CHANNEL/CHAT PAGE (Same as before, used for both DM and Server Channel chats) ---
// This page displays a conversation (either DM or server channel)
// Shows the message thread and a text input field for typing messages
class ChannelPage extends StatelessWidget { // GLO9
  final String channelName;               // Name of the DM person/group or channel
  final bool isDM;                        // Whether this is a DM conversation (true) or server channel (false)
  final Color avatarColor;                // Color for the avatar/icon in the app bar

  const ChannelPage({
    super.key,
    required this.channelName,
    this.isDM = false,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F), // Chat background color
      
      // App Bar with back button, channel name, and action buttons
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F3136), // Slightly lighter header color
        elevation: 0,
        titleSpacing: 0,
        
        // Back button to return to previous page
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        
        // Title section with icon and channel name
        title: Row(
          children: [
            // Show different icon based on whether this is DM or server channel
            if (isDM) 
              // DM Icon in AppBar - circular avatar
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            if (!isDM)
              // Text Channel Icon in AppBar - hash symbol
              const Icon(Icons.numbers_outlined, color: Colors.white70, size: 24),

            const SizedBox(width: 8),
            
            // Channel/DM name
            Text(
              channelName,
              style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        
        // Action buttons on the right (call and more options)
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.call, color: Colors.white, size: 24),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, color: Colors.white, size: 24),
          ),
        ],
      ),
      
      // Main body with message area and input field
      body: Column(
        children: [
          // Message display area (currently shows placeholder text)
          Expanded(
            child: Center(
              child: Text(
                'Chat with $channelName',
                style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 16),
              ),
            ),
          ),
          
          // Chat input field at the bottom
          const ChatInputField(),
        ],
      ),
    );
  }
} // GLO9

// --- Chat Input Widget ---
// Displays a text input field with attach/emoji buttons for composing messages
class ChatInputField extends StatelessWidget { // SHELLY3
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 16, right: 16),
      color: const Color(0xFF36393F), // Match chat background
      child: Row(
        children: [
          // Plus Icon (for media/attachments)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.add_circle, color: Color(0xFFB5B5B5), size: 28),
          ),
          
          // Text input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF40444B), // Input background color
                borderRadius: BorderRadius.circular(25), // Rounded pill shape
              ),
              child: TextField(
                style: GoogleFonts.montserrat(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Message #channel',
                  hintStyle: GoogleFonts.montserrat(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          
          // Send/Emoji Icon
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.send, color: Color(0xFFB5B5B5), size: 28),
          ),
        ],
      ),
    );
  }
} // SHELLY3

// ==========================================================
// --- NEW SERVER CREATION/JOIN FLOW WIDGETS ---
// ==========================================================

// --- 4. Create Server Page (Matches Image 1) ---
// This page allows users to create a new server from scratch or from a template
// Shows options to "Create My Own" or choose from templates like Gaming, School Club, etc.
class CreateServerPage extends StatelessWidget { // SHELLY4
  const CreateServerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3136), // Dark background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Icon - dismisses this page
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title and Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      'Create Your Server',
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your server is where you and your friends hang out.\nMake yours and start talking.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Create My Own Button - for creating a custom server from scratch
              _ServerOptionItem(
                title: 'Create My Own',
                icon: Icons.brush_rounded, // Using a suitable material icon
                iconColor: const Color(0xFF3B9E78),
                backgroundColor: const Color(0xFF40444B),
                onTap: () {
                  // Placeholder for starting creation flow
                },
              ),
              
              const SizedBox(height: 32),
              
              // Templates Section Header
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  'Start from a template',
                  style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              
              // Template List - predefined server templates with specific purposes
              _ServerOptionItem(title: 'Gaming', icon: Icons.gamepad_rounded, iconColor: Colors.blueAccent, isTemplate: true),
              _ServerOptionItem(title: 'School Club', icon: Icons.school_rounded, iconColor: Colors.redAccent, isTemplate: true),
              _ServerOptionItem(title: 'Study Group', icon: Icons.lightbulb_outline_rounded, iconColor: Colors.pink, isTemplate: true),
              _ServerOptionItem(title: 'Friends', icon: Icons.favorite_rounded, iconColor: Colors.purple, isTemplate: true),
              _ServerOptionItem(title: 'Artists & Creators', icon: Icons.palette_rounded, iconColor: Colors.teal, isTemplate: true),
              _ServerOptionItem(title: 'Local Community', icon: Icons.people_outline_rounded, iconColor: Colors.lightGreen, isTemplate: true),
              
              const SizedBox(height: 60),

              // Join Server Prompt
              Center(
                child: Text(
                  'Already have an invite?',
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              
              // Join Server Button (Blue accent button)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Join Server Page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const JoinServerPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5865F2), // Discord blue
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Join a Server',
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} // SHELLY4

// --- Reusable Server Option Item (for CreateServerPage) ---
// Displays a single server creation option (template or custom)
class _ServerOptionItem extends StatelessWidget { // SHELLY5
  final String title;                     // Name of the template or option
  final IconData icon;                    // Icon representing the option
  final Color iconColor;                  // Color of the icon
  final Color backgroundColor;            // Background color of the item
  final VoidCallback? onTap;              // Callback when tapped
  final bool isTemplate;                  // Whether this is a template (visual indicator)

  const _ServerOptionItem({
    required this.title,
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.onTap,
    this.isTemplate = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // SHELLY5

// --- 5. Join Server Page (Matches Image 2) ---
// This page allows users to join an existing server using an invite link
// Also provides an option to join a Student Hub
class JoinServerPage extends StatelessWidget { // MICHAEL7 
  const JoinServerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F3136), // Dark background
      
      // App Bar with back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Join an existing server',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Enter an invite below to join an existing server.',
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Invite Link Label
            Text(
              'Invite link',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            // Invite Link Input Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F22),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                style: GoogleFonts.montserrat(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'https://discord.gg/hTKzmak',
                  hintStyle: GoogleFonts.montserrat(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Help Text - explains the format of invite links
            Text(
              'Invites should look like https://discord.gg/hTKzmak, hTKzmak or\nhttps://discord.gg/wumpus-friends',
              style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 60),

            // Join with Invite Link Button - primary action (blue)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder action for joining with invite
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5865F2), // Discord blue
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Join with Invite Link',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // OR Divider - separates the two join methods
            Center(
              child: Text(
                'OR',
                style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Join a Student Hub Button - secondary action (dark gray)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder action for student hub
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40444B), // Darker button for secondary action
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Join a Student Hub',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} //MICHAEL7