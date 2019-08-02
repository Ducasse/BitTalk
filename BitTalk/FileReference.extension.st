Extension { #name : #FileReference }

{ #category : #'*BitTalk' }
FileReference >> asOrderedCollection [
	^self asOrderedCollectionUpTo: FileSystem root	

	
]

{ #category : #'*BitTalk' }
FileReference >> asOrderedCollectionUpTo: topFileReference [
	| ordCollect fr |
	ordCollect := OrderedCollection new.
	fr := self.
	[ topFileReference ~= fr ]
		whileTrue: [ 
			ordCollect addFirst: fr basename.
			fr := fr parent ].
	^ ordCollect
]

{ #category : #'*BitTalk' }
FileReference >> bencoded [
	^self asOrderedCollection bencoded
]

{ #category : #'*BitTalk' }
FileReference >> isTorrent [
	^self isFile and:[self extension = self class metainfoExtension]
]

{ #category : #'*BitTalk' }
FileReference class >> metainfoExtension [
	^'torrent'
]

{ #category : #'*BitTalk' }
FileReference >> resolveConflict [
	|   int    parent basename    extension basenameWithoutExt  | 
	self isRoot 
		ifTrue:[^ self].
	parent:= self parent.
	basename:= self basename.
	int:=1.
	[(parent / basename) exists]
		whileTrue: [
			basenameWithoutExt:=self basenameWithoutExtension.
			extension:=self extension.
			basename:= basenameWithoutExt , '(',int asString,')','.',extension.
			int:=int+1.
		].
	 ^parent / basename. 
]
