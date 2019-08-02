Class {
	#name : #BtBencodingTest,
	#superclass : #TestCase,
	#category : #'BitTalk-Tests'
}

{ #category : #tests }
BtBencodingTest >> testDecoding [
	| bytes1 bytes2 bytes3 bytes4 bytes5 bytes6       list1 dict1 dict2 bytes7 bytes8 dict3 bytes0 |
	bytes0:='0:' asByteArray .
	self assert: bytes0 bedecoded = ''.
	
	bytes1:='1:a' asByteArray.
	self assert: bytes1 bedecoded = 'a'.
		
	bytes2:='i0e' asByteArray .
	self assert: bytes2 bedecoded = 0.		
	bytes3:='i12345678910e' asByteArray.
	self assert: bytes3 bedecoded = 12345678910.	
		
	bytes4:='le' asByteArray .
	self assert: bytes4 bedecoded = OrderedCollection new.
	bytes5:='l' asByteArray , bytes1 , bytes2, bytes3, bytes4, 'e' asByteArray .
	list1:=(OrderedCollection withAll: #('a' 0 12345678910)) add: OrderedCollection new; yourself.
	self assert: bytes5 bedecoded = list1.
		
	bytes6:='d' asByteArray , '4:key1' asByteArray , bytes5 , '4:key2' asByteArray ,'de' asByteArray ,'e' asByteArray .
	dict1:=Dictionary new at:'key1'put: list1; at:'key2' put: Dictionary new;yourself.
	self assert: (bytes6 bedecoded = dict1 and:[bytes6 bedecoded class = Dictionary ]).
	
	bytes7:='d' asByteArray , '4:key1' asByteArray , bytes5 , '4:key2' asByteArray ,'de' asByteArray ,'4:info' asByteArray , 'de' asByteArray ,'e' asByteArray .		
	dict2:= Dictionary new at:'key1'put: list1; at:'key2' put: Dictionary new; at:'info' put: Dictionary new; yourself.
	self assert: bytes7 bedecoded = dict2.
	
	bytes8:='d' asByteArray, '4:key1' asByteArray, bytes5, '4:key2' asByteArray,'de' asByteArray,'5:peers' asByteArray, '1:' asByteArray,#[45],'e' asByteArray.
	dict3:= Dictionary new at:'key1'put: list1; at:'key2' put: Dictionary new; at:'peers' put: #[45] asString ; yourself.
	self assert: bytes8 bedecoded = dict3 .
	
]

{ #category : #tests }
BtBencodingTest >> testEncoding [

	|  string1 integer1 integer2 integer3 list1  list2 metainfo1 metainfo2 string0 |
	string0:=''.
	self assert: string0 bencoded = '0:' asByteArray.
	string1:='a'.
	self assert: string1 bencoded = '1:a' asByteArray.
	 
	integer1 := 0.
	self assert: integer1 bencoded = 'i0e' asByteArray.
	integer2:= 00.
	self assert: integer2 bencoded = 'i0e' asByteArray.
	integer3:= 01.
	self assert: integer3 bencoded = 'i1e' asByteArray.
	
	list1:=OrderedCollection new.
	self assert: list1 bencoded = 'le' asByteArray .
	list2:= OrderedCollection new add: string1; add: integer3 ; add: list1; yourself  .
	self assert: list2 bencoded = 'l1:ai1elee' asByteArray .
	
	metainfo1:=Dictionary new at:'a'put: list2 ; yourself.
	self assert: metainfo1 bencoded =  'd1:al1:ai1eleee' asByteArray .
	metainfo2:=Dictionary new at:'0123456789' put: metainfo1 ; yourself.
	self assert: metainfo2 bencoded = 'd10:0123456789d1:al1:ai1eleeee' asByteArray .
]

{ #category : #tests }
BtBencodingTest >> testFileReference [
	| ref1 ref2 top |
	self assert: OrderedCollection new asFileReference = FileSystem root.
	self assert: (OrderedCollection withAll: #('a' 'b' 'c')) asFileReference = (FileSystem root / 'a' / 'b' / 'c').
	self assert: (OrderedCollection with: 'a') asFileReference = (FileSystem root / 'a').
	self assert: OrderedCollection new asFileReference = FileSystem root.
	top := '/dir1' asFileReference.
	ref1 := '/dir1/dir2/dir3' asFileReference.
	self assert: (ref1 asOrderedCollectionUpTo: top) = #('dir2' 'dir3') asOrderedCollection.
	ref2 := '/dir1' asFileReference.
	self assert: (ref2 asOrderedCollectionUpTo: top) = OrderedCollection new.
	self assert: (ref1 asOrderedCollectionUpTo: FileSystem root) = #('dir1' 'dir2' 'dir3') asOrderedCollection.
	self assert: (FileSystem root asOrderedCollectionUpTo: FileSystem root) = OrderedCollection new
]

{ #category : #tests }
BtBencodingTest >> testInverseFunction [
	| int string list dict |
	int:= 12345.
	string:= 'hello world'.
	list:= OrderedCollection new.
	list add: 12345; add: string.
	dict:= Dictionary new.
	dict at: string put: int.
	self assert: int = int bencoded bedecoded.
	self assert: string = string bencoded bedecoded.
	self assert: list = list bencoded bedecoded . 
	self assert: dict = dict bencoded bedecoded .
]
