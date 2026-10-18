import 'package:flutter/material.dart';
import 'package:vaxi_track/features/user_management/presentation/user_management_page.dart';
import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/services/auth_service.dart';
import '../models/managed_user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _auth = AuthService();
  final _service = UserManagementService.instance;
  final _searchController = TextEditingController();
  String _search = '';
  UserRole? _roleFilter;
  bool? _activeFilter;

  bool get _canManage =>
      _auth.currentUser != null &&
      RolePermissions.canManageUsers(_auth.currentUser!.role);
  List<ManagedUser> get _filtered => _service.users.where((u) {
    final q = _search.trim().toLowerCase();
    return (q.isEmpty ||
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.id.toLowerCase().contains(q)) &&
        (_roleFilter == null || u.role == _roleFilter) &&
        (_activeFilter == null || u.isActive == _activeFilter);
  }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canManage)
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 54, color: Colors.redAccent),
                SizedBox(height: 12),
                Text(
                  'Access restricted',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Only administrators can manage users.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add User'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _intro(),
            const SizedBox(height: 16),
            _summary(),
            const SizedBox(height: 20),
            const Text(
              'All users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search name, email or user ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<UserRole?>(
              value: _roleFilter,
              isExpanded: true,
              decoration: _decoration('Filter by role'),
              items: [
                const DropdownMenuItem<UserRole?>(
                  value: null,
                  child: Text('All roles'),
                ),
                ...UserRole.values.map(
                  (r) => DropdownMenuItem<UserRole?>(
                    value: r,
                    child: Text(_roleName(r)),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _roleFilter = v),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<bool?>(
              value: _activeFilter,
              isExpanded: true,
              decoration: _decoration('Filter by status'),
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                DropdownMenuItem<bool?>(value: true, child: Text('Active')),
                DropdownMenuItem<bool?>(value: false, child: Text('Inactive')),
              ],
              onChanged: (v) => setState(() => _activeFilter = v),
            ),
            const SizedBox(height: 12),
            if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No users match your filters.')),
              )
            else
              ..._filtered.map(_userCard),
            const SizedBox(height: 10),
            Text(
              '${_filtered.length} of ${_service.totalUsers} users shown · Demo data stored in memory',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intro() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6DBDEE), Color(0xFF0063B6), Color(0xFF000C6E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.manage_accounts_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'People & access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Manage team accounts and assign system roles.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _summary() => Row(
    children: [
      Expanded(
        child: _summaryCard(
          'Total',
          _service.totalUsers,
          Icons.groups_rounded,
          const Color(0xFF2478C8),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: _summaryCard(
          'Active',
          _service.activeUsers,
          Icons.verified_user_rounded,
          const Color(0xFF168653),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: _summaryCard(
          'Inactive',
          _service.inactiveUsers,
          Icons.person_off_rounded,
          const Color(0xFFB7791F),
        ),
      ),
    ],
  );
  Widget _summaryCard(String label, int value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );
  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _userCard(ManagedUser user) {
    final color = _roleColor(user.role);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.12),
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _chip(user.roleName, color),
                      _chip(
                        user.isActive ? 'Active' : 'Inactive',
                        user.isActive ? const Color(0xFF168653) : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.id,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'view') _details(user);
                if (v == 'edit') _showForm(user: user);
                if (v == 'toggle') _toggle(user);
                if (v == 'delete') _delete(user);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Text('View details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit user')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    user.isActive ? 'Deactivate account' : 'Activate account',
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete demo record',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(.10),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );

  Future<void> _showForm({ManagedUser? user}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    UserRole selectedRole = user?.role ?? UserRole.warehouseStaff;
    final isEditing = user != null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit user' : 'Add new user'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                          ? 'Enter the user’s full name.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter an email address.';
                        }
                        return _service.validateEmail(
                          value,
                          excludeUserId: user?.id,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      value: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Assign role',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: UserRole.values
                          .map(
                            (role) => DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(_roleName(role)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRole = value);
                        }
                      },
                    ),
                    if (!isEditing)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'This creates a local demo record only. It does not create a Firebase Authentication account.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                try {
                  if (isEditing) {
                    _service.updateUser(
                      user.id,
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                    );
                  } else {
                    _service.addUser(
                      name: nameController.text,
                      email: emailController.text,
                      role: selectedRole,
                    );
                  }
                  Navigator.pop(dialogContext);
                  setState(() {});
                  _message(isEditing ? 'User updated.' : 'User added.');
                } on StateError catch (error) {
                  _message(error.message.toString(), error: true);
                }
              },
              child: Text(isEditing ? 'Save changes' : 'Add user'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    emailController.dispose();
  }

  void _details(ManagedUser u) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('User details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detail('User ID', u.id),
          _detail('Full name', u.name),
          _detail('Email', u.email),
          _detail('Role', u.roleName),
          _detail('Status', u.isActive ? 'Active' : 'Inactive'),
          _detail('Created', _date(u.createdAt)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Future<void> _toggle(ManagedUser user) async {
    final activate = !user.isActive;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activate ? 'Activate user?' : 'Deactivate user?'),
        content: Text(
          'Are you sure you want to ${activate ? 'activate' : 'deactivate'} ${user.name}’s account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(activate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      _service.setActive(user.id, activate);
      setState(() {});
      _message(activate ? 'Account activated.' : 'Account deactivated.');
    } on StateError catch (e) {
      _message(e.message.toString(), error: true);
    }
  }

  Future<void> _delete(ManagedUser user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete demo record?'),
        content: Text(
          'Remove ${user.name} from the local demo user list? This does not delete a Firebase account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      _service.deleteUser(user.id);
      setState(() {});
      _message('Demo user record deleted.');
    } on StateError catch (e) {
      _message(e.message.toString(), error: true);
    }
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _roleName(UserRole r) => switch (r) {
    UserRole.admin => 'Admin',
    UserRole.warehouseStaff => 'Warehouse Staff',
    UserRole.salesRepresentative => 'Sales Representative',
    UserRole.facilityStaff => 'Facility Staff',
    UserRole.pharmacist => 'Pharmacist',
  };
  Color _roleColor(UserRole r) => switch (r) {
    UserRole.admin => const Color(0xFF6D4CBB),
    UserRole.warehouseStaff => const Color(0xFF2478C8),
    UserRole.salesRepresentative => const Color(0xFF00897B),
    UserRole.facilityStaff => const Color(0xFFB7791F),
    UserRole.pharmacist => const Color(0xFF168653),
  };
}
