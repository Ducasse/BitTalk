"
A BtFileCollectionTest is a test class for testing the behavior of BtFileCollection
"
Class {
	#name : #BtFileCollectionTest,
	#superclass : #TestCase,
	#instVars : [
		'testsDirectory',
		'sharing',
		'storeName',
		'storeLocation',
		'fileNameA',
		'fileNameB',
		'btFileA',
		'btFileB',
		'fileA',
		'fileB',
		'fileCollection'
	],
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtFileCollectionTest >> setCase1 [
	fileA
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '1234' asByteArray.
			x truncate: x position ].
	btFileA := BtFile new
		finalSize: 4;
		reference: fileA.
	fileB
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '5678' asByteArray.
			x truncate: x position ].
	btFileB := BtFile new
		finalSize: 4;
		reference: fileB.
	fileCollection := BtFileCollection withAll: (OrderedCollection with: btFileA with: btFileB)
]

{ #category : #running }
BtFileCollectionTest >> setCase2 [	
	fileA
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '1234' asByteArray.
			x truncate: x position ].
	btFileA := BtFile new
		finalSize: 4;
		reference: fileA.
	fileB
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '56' asByteArray.
			x truncate: x position ].
	btFileB := BtFile new
		finalSize: 4;
		reference: fileB.
	fileCollection := BtFileCollection withAll: (OrderedCollection with: btFileA with: btFileB)
]

{ #category : #running }
BtFileCollectionTest >> setCase3 [	
	fileA
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '12' asByteArray .
			x truncate: x position ].
	btFileA := BtFile new
		finalSize: 4;
		reference: fileA.
	fileB
		writeStreamDo: [ :x | 
			x binary.
			x nextPutAll: '56' asByteArray .
			x truncate: x position ].
	btFileB := BtFile new
		finalSize: 4;
		reference: fileB.
	fileCollection := BtFileCollection withAll: (OrderedCollection with: btFileA with: btFileB)
]

{ #category : #running }
BtFileCollectionTest >> setEmpty [
	fileA
		writeStreamDo: [ :x | 
			x binary.
			x truncate: x position ].
	btFileA := BtFile new
		finalSize: 4;
		reference: fileA.
	fileB
		writeStreamDo: [ :x | 
			x binary.
			x truncate: x position ].
	btFileB := BtFile new
		finalSize: 4;
		reference: fileB.
	fileCollection := BtFileCollection withAll: (OrderedCollection with: btFileA with: btFileB)
]

{ #category : #running }
BtFileCollectionTest >> setUp [
	testsDirectory := FileSystem workingDirectory / 'BitTalkTests'.
	testsDirectory ensureCreateDirectory.
	sharing := testsDirectory / 'sharing'.
	sharing ensureCreateDirectory.
	storeName := 'store'.
	storeLocation := sharing / storeName.
	storeLocation ensureCreateDirectory.
	fileNameA := 'fileA'.
	fileNameB := 'fileB'.
	fileA := storeLocation / fileNameA.
	fileA ensureCreateFile.
	fileB := storeLocation / fileNameB.
	fileB ensureCreateFile.
	btFileA := BtFile new.
	btFileB := BtFile new
]

{ #category : #running }
BtFileCollectionTest >> tearDown [
	testsDirectory ensureDeleteAll
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testAllSha1SplitEvery [
	| pieceLength |
	pieceLength := 8.
	self setCase1.
	self
		assert: (fileCollection allSha1SplitEvery: pieceLength) = (SHA1 hashStream: '12345678' asByteArray readStream).
	pieceLength := 4.
	self
		assert:
			(fileCollection allSha1SplitEvery: pieceLength)
				= ((SHA1 hashStream: '1234' asByteArray readStream) , (SHA1 hashStream: '5678' asByteArray readStream)).
	pieceLength := 6.
	self
		assert:
			(fileCollection allSha1SplitEvery: pieceLength)
				= ((SHA1 hashStream: '123456' asByteArray readStream) , (SHA1 hashStream: '78' asByteArray readStream))
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testCheckAllComplete [
	self setCase1.
	self shouldnt: [ fileCollection checkAllComplete ] raise: Error.
	self setCase2.
	self should: [ fileCollection checkAllComplete ] raise: Error.
	self setCase3.
	self should: [ fileCollection checkAllComplete ] raise: Error
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testCheckOffsetAmount [
	self setCase1.
	self shouldnt: [ fileCollection checkOffset: 0 amount: 8 ] raise: Error.
	self should: [ fileCollection checkOffset: -1 amount: 8 ] raise: Error.
	self should: [ fileCollection checkOffset: 0 amount: 9 ] raise: Error.
	self should: [ fileCollection checkOffset: 1 amount: 8 ] raise: Error
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testFilesToReadFirstOffsetAmount [
	self setCase1.
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 1) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 4) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 5) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 8) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToReadFirst: 1 offset: 3 amount: 1) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToReadFirst: 1 offset: 3 amount: 2) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToReadFirst: 1 offset: 3 amount: 5) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToReadFirst: 2 offset: 0 amount: 1) = (OrderedCollection with: btFileB).
	self assert: (fileCollection filesToReadFirst: 2 offset: 3 amount: 1) = (OrderedCollection with: btFileB).
	self setCase2.
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 6) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 7) isNil.
	self setCase3.
	self assert: (fileCollection filesToReadFirst: 1 offset: 0 amount: 2) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToReadFirst: 2 offset: 0 amount: 2) = (OrderedCollection with: btFileB)
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testFilesToWriteFirstOffsetAmount [
	self setCase1.
	self assert: (fileCollection filesToWriteFirst: 1 offset: 0 amount: 1) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 0 amount: 4) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 0 amount: 5) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 0 amount: 8) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 3 amount: 1) = (OrderedCollection with: btFileA).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 3 amount: 2) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToWriteFirst: 1 offset: 3 amount: 5) = (OrderedCollection with: btFileA with: btFileB).
	self assert: (fileCollection filesToWriteFirst: 2 offset: 0 amount: 1) = (OrderedCollection with: btFileB).
	self assert: (fileCollection filesToWriteFirst: 2 offset: 3 amount: 1) = (OrderedCollection with: btFileB).
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testFirstFileIndex [
	self setCase1.
	self assert: (fileCollection firstFileIndex: 0) = 1.
	self assert: (fileCollection firstFileIndex: 1) = 1.
	self assert: (fileCollection firstFileIndex: 3) = 1.
	self assert: (fileCollection firstFileIndex: 4) = 2.
	self assert: (fileCollection firstFileIndex: 5) = 2.
	self assert: (fileCollection firstFileIndex: 7) = 2
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testFirstFileOffset [
	self setCase1.
	self assert: (fileCollection firstFileOffset: 0) = 0.
	self assert: (fileCollection firstFileOffset: 1) = 1.
	self assert: (fileCollection firstFileOffset: 3) = 3.
	self assert: (fileCollection firstFileOffset: 4) = 0.
	self assert: (fileCollection firstFileOffset: 5) = 1.
	self assert: (fileCollection firstFileOffset: 7) = 3
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testReadOffsetAmount [
	self setCase1.
	self should: [ fileCollection readOffset: -1 amount: 3 ] raise: Error.
	self should: [ fileCollection readOffset: 0 amount: 9 ] raise: Error.
	self assert: (fileCollection readOffset: 0 amount: 8) = '12345678' asByteArray.
	self assert: (fileCollection readOffset: 1 amount: 7) = '2345678' asByteArray.
	self assert: (fileCollection readOffset: 0 amount: 4) = '1234' asByteArray.
	self assert: (fileCollection readOffset: 4 amount: 4) = '5678' asByteArray.
	self setCase2.
	self assert: (fileCollection readOffset: 0 amount: 6) = '123456' asByteArray.
	self assert: (fileCollection readOffset: 0 amount: 7) isNil.
	self assert: (fileCollection readOffset: 4 amount: 2) = '56' asByteArray.
	self setCase3.
	self assert: (fileCollection readOffset: 0 amount: 2) = '12' asByteArray.
	self assert: (fileCollection readOffset: 4 amount: 2) = '56' asByteArray.
	self assert: (fileCollection readOffset: 4 amount: 3) isNil
]

{ #category : #'tests-operations' }
BtFileCollectionTest >> testWriteOffsetData [
	self setEmpty.
	self should: [ fileCollection writeOffset: -1 data: 3 ] raise: Error.
	self should: [ fileCollection writeOffset: 0 data: 9 ] raise: Error.
	fileCollection writeOffset: 0 data: '12345678' asByteArray.	
	self assert: (fileCollection readOffset: 0 amount: 8) = '12345678' asByteArray.
	self setEmpty.
	fileCollection writeOffset: 3 data: '45' asByteArray.	
	self assert: (fileCollection readOffset: 0 amount: 5) = #[0 0 0 52 53].
	self assert: (fileCollection readOffset: 0 amount: 6) isNil

]
