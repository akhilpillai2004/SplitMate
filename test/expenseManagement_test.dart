import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:split_mate/core/failure.dart';
import 'package:split_mate/models/expense_model.dart';
import 'package:split_mate/models/user_model.dart';
import 'package:split_mate/features/expense/repository/expense_repository.dart';

// Generate mocks with correct generic types
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>
])
import 'expenseManagement_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockExpensesCollection;
  late ExpenseRepository expenseRepository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockExpensesCollection = MockCollectionReference<Map<String, dynamic>>();
    
    // Configure the mock Firestore to return the mock collection
    when(mockFirestore.collection(any)).thenReturn(mockExpensesCollection);
    
    expenseRepository = ExpenseRepository(firestore: mockFirestore);
  });

  // Test data
  final testUser = UserModel(
    uid: '1', 
    username: 'testUser', 
    email: 'test@example.com',
    name: 'testUser',
    profilePic: 'default-icon',
    isAuthenticated: true,
    friendsList: ['friend1'],
  );

  final testExpense = ExpenseModel(
    expenseId: 'expense1',
    description: 'Test Expense',
    amount: 100.0,
    date: DateTime.now(),
    paidBy: 'user1',
    splitWith: [testUser],
    timestamp: DateTime.now(),
  );

  group('ExpenseRepository', () {
    test('createExpense - successful', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockExpensesCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.set(any)).thenAnswer((_) async => Future.value());

      // Act
      final result = await expenseRepository.createExpense(testExpense);

      // Assert
      expect(result.isRight(), true);
      verify(mockExpensesCollection.doc(testExpense.expenseId)).called(1);
      verify(mockDocRef.set(testExpense.toMap())).called(1);
    });

    test('createExpense - Firebase exception', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockExpensesCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.set(any)).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'test-error')
      );

      // Act
      final result = await expenseRepository.createExpense(testExpense);

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<Failure>());
    });

    test('fetchExpenses - returns correct list', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      // Create a map that represents the expense data
      final expenseMap = testExpense.toMap();
      
      // Setup mocking for Firestore query
      when(mockExpensesCollection.where(
        'splitWith', 
        arrayContains: testUser.uid
      )).thenReturn(mockExpensesCollection);

      // Create a stream that emits a QuerySnapshot
      final stream = Stream.fromFuture(Future.value(mockQuerySnapshot));
      when(mockExpensesCollection.snapshots()).thenAnswer((_) => stream);

      // Setup docs to return our mock document
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.data()).thenReturn(expenseMap);

      // Act
      final expensesStream = expenseRepository.fetchExpenses(testUser.uid);

      // Assert
      await expectLater(
        expensesStream,
        emits(allOf([
          isList,
          hasLength(1),
          contains(isA<ExpenseModel>()),
          // Optional: check specific properties if needed
          predicate((List<ExpenseModel> expenses) => 
            expenses.first.expenseId == testExpense.expenseId)
        ]))
      );
    });

    test('updateExpenseAmount - successful', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockExpensesCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenAnswer((_) async => Future.value());

      // Act
      final result = await expenseRepository.updateExpenseAmount(
        testExpense.expenseId, 
        200.0
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockExpensesCollection.doc(testExpense.expenseId)).called(1);
      verify(mockDocRef.update({'amount': 200.0})).called(1);
    });

    test('updateExpenseAmount - failure', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockExpensesCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenThrow(Exception('Update failed'));

      // Act
      final result = await expenseRepository.updateExpenseAmount(
        testExpense.expenseId, 
        200.0
      );

      // Assert
      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null);
      expect(failure, isA<Failure>());
    });
  });
}