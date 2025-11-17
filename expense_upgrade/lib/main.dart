import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/security/session_manager.dart';
import 'core/security/encryption_service.dart';

// Data
import 'data/services/firebase_auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/category_service.dart';
import 'data/services/sync_service.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';

// Domain
import 'domain/usecases/auth_usecase.dart';
import 'domain/usecases/transaction_usecase.dart';
import 'domain/usecases/category_usecase.dart';

// Presentation
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/widgets/auth_wrapper.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/add_transaction_screen.dart';
import 'presentation/screens/transaction_screen.dart';
import 'presentation/screens/analytics_screen.dart';
import 'presentation/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),
        Provider<EncryptionService>(
          create: (_) => EncryptionService(),
        ),
        ProxyProvider<LocalStorageService, SessionManager>(
          update: (_, localStorageService, __) => SessionManager(
            localStorageService: localStorageService,
          ),
        ),
        
        // Auth services
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        
        // Data services
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<CategoryService>(
          create: (_) => CategoryService(),
        ),
        ProxyProvider2<LocalStorageService, FirestoreService, SyncService>(
          update: (_, localStorageService, firestoreService, __) => SyncService(
            localStorageService: localStorageService,
            firestoreService: firestoreService,
          ),
        ),
        
        // Repositories
        ProxyProvider3<FirestoreService, LocalStorageService, SyncService, TransactionRepositoryImpl>(
          update: (_, firestoreService, localStorageService, syncService, __) => TransactionRepositoryImpl(
            firestoreService: firestoreService,
            localStorageService: localStorageService,
            syncService: syncService,
          ),
        ),
        ProxyProvider2<CategoryService, LocalStorageService, CategoryRepositoryImpl>(
          update: (_, categoryService, localStorageService, __) => CategoryRepositoryImpl(
            categoryService: categoryService,
            localStorageService: localStorageService,
          ),
        ),
        
        // Use cases
        ProxyProvider<FirebaseAuthService, AuthUseCase>(
          update: (_, authService, __) => AuthUseCase(authService),
        ),
        ProxyProvider<TransactionRepositoryImpl, TransactionUseCase>(
          update: (_, transactionRepo, __) => TransactionUseCase(transactionRepo),
        ),
        ProxyProvider<CategoryRepositoryImpl, CategoryUseCase>(
          update: (_, categoryRepo, __) => CategoryUseCase(categoryRepo),
        ),
        
        // Providers
        ChangeNotifierProxyProvider4<FirebaseAuthService, SessionManager, EncryptionService, LocalStorageService, AuthProvider>(
          create: (context) => AuthProvider(
            authRepository: context.read<FirebaseAuthService>(),
            sessionManager: context.read<SessionManager>(),
            encryptionService: context.read<EncryptionService>(),
            localStorageService: context.read<LocalStorageService>(),
            secureStorage: const FlutterSecureStorage(),
          ),
          update: (_, authService, sessionManager, encryptionService, localStorageService, previous) =>
              previous ?? AuthProvider(
                authRepository: authService,
                sessionManager: sessionManager,
                encryptionService: encryptionService,
                localStorageService: localStorageService,
                secureStorage: const FlutterSecureStorage(),
              ),
        ),
        
        ChangeNotifierProxyProvider4<TransactionUseCase, AuthProvider, SyncService, LocalStorageService, TransactionProvider>(
          create: (context) => TransactionProvider(
            transactionUseCase: context.read<TransactionUseCase>(),
            authProvider: context.read<AuthProvider>(),
            syncService: context.read<SyncService>(),
            localStorageService: context.read<LocalStorageService>(),
          ),
          update: (_, transactionUseCase, authProvider, syncService, localStorageService, previous) =>
              previous ?? TransactionProvider(
                transactionUseCase: transactionUseCase,
                authProvider: authProvider,
                syncService: syncService,
                localStorageService: localStorageService,
              ),
        ),
        
        ChangeNotifierProxyProvider2<CategoryUseCase, AuthProvider, CategoryProvider>(
          create: (context) => CategoryProvider(
            categoryUseCase: context.read<CategoryUseCase>(),
            authProvider: context.read<AuthProvider>(),
          ),
          update: (_, categoryUseCase, authProvider, previous) =>
              previous ?? CategoryProvider(
                categoryUseCase: categoryUseCase,
                authProvider: authProvider,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Quản lý Chi tiêu',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const MainNavigation(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/transactions': (context) => const TransactionScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
      ),
    );
  }
}