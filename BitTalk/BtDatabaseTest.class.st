"
A BtDatabaseTest is a test class for testing the behavior of BtDatabase
"
Class {
	#name : #BtDatabaseTest,
	#superclass : #TestCase,
	#instVars : [
		'testsDirectory',
		'location1',
		'location2',
		'metainfoFile1'
	],
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtDatabaseTest >> setUp [
	BtDatabase initialize .
	testsDirectory:=FileSystem workingDirectory / 'BitTalkTests' .  
	testsDirectory ensureCreateDirectory.
	location1:=testsDirectory / 'database1'.
	location2:=testsDirectory / 'database2'.
	metainfoFile1:= testsDirectory / 'metainfo1.torrent'.
]

{ #category : #running }
BtDatabaseTest >> tearDown [
	testsDirectory ensureDeleteAll
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testDelete [
	| database |
	database:=BtDatabase new.
	database location: location1 .
	self assert: database location exists.
	database delete.
	self deny: location1 exists.
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testDeleteAttribute [
	| database attribute value1 value2 |
	database := BtDatabase new.
	database location: location1.
	attribute := 'attribute'.
	value1 := 'value1'.
	value2 := 'value2'.
	self assert: (database select: attribute) isNil.
	database update: attribute value: value1.
	self assert: (database select: attribute) = value1.
	database deleteAttribute: attribute.
	self assert: (database select: attribute) isNil.
	database update: attribute value: value2.
	self assert: (database select: attribute) = value2.
	database deleteAttribute: attribute.
	self assert: (database select: attribute) isNil
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testLocation [
	| database     oldChildren oldLocation newLocation |
	location1 ensureDeleteAll .
	self deny: location1 exists.
	
	database:=BtDatabase new.
	database location: location1 .
	self assert: ((location1 = database location) and:[location1 exists]).
	oldChildren:= location1 children .
	oldLocation:= location1 parent / (location1 basename).
	newLocation:= location1 parent / (location2 basename).
	database location: location2 .
	self assert: newLocation = database location .
	self assert: oldLocation exists not .
	self assert: newLocation exists .
	self assert: (newLocation children) = oldChildren.
	
	oldChildren:= location2 children .
	oldLocation:= location2 parent / (location2 basename).
	newLocation:= location2 parent / (location2 basename).
	database location: location2 .
	self assert: newLocation = database location .
	self assert: oldLocation exists .
	self assert: newLocation exists .
	self assert: (newLocation children) = oldChildren.
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testMetainfoFile [
	| database |
	metainfoFile1 ensureCreateFile.
	metainfoFile1
		writeStreamDo: [ :x | 
			x nextPutAll: 'hello'.
			x truncate: x position ].
	database := BtDatabase new.
	database location: location1.
	self assert: database metainfoFile isNil.
	database metainfoFile: metainfoFile1.
	database metainfoFile readStreamDo: [ :x | self assert: x contents = 'hello' ].
	metainfoFile1
		writeStreamDo: [ :x | 
			x nextPutAll: 'hello world'.
			x truncate: x position ].
	database metainfoFile: metainfoFile1.
	database metainfoFile readStreamDo: [ :x | self assert: x contents = 'hello world' ]
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testSelect [
	| database attribute value1 value2 |
	database := BtDatabase new.
	database location: location1.
	attribute := 'attribute'.
	value1 := 'value1'.
	value2 := 'value2'.
	self assert: (database select: attribute) isNil.
	database update: attribute value: value1.
	self assert: (database select: attribute) = value1.
	database update: attribute value: value2.
	self assert: (database select: attribute) = value2
]

{ #category : #'tests-accessing' }
BtDatabaseTest >> testUpdateValue [
	| database attribute value1 value2 |
	database := BtDatabase new.
	database location: location1.
	attribute := 'attribute'.
	value1 := 'value1'.
	value2 := 'value2'.
	self assert: (database select: attribute) isNil.
	database update: attribute value: value1.
	self assert: (database select: attribute) = value1.
	database update: attribute value: value2.
	self assert: (database select: attribute) = value2
]
