"
Represento un fichero presente en el contenido de un torrent.

"
Class {
	#name : #BtFile,
	#superclass : #Object,
	#instVars : [
		'finalSize',
		'reference'
	],
	#category : #'BitTalk-DataAccess'
}

{ #category : #accessing }
BtFile >> currentSize [
	^reference size
]

{ #category : #accessing }
BtFile >> finalSize [
	^ finalSize
]

{ #category : #accessing }
BtFile >> finalSize: anInteger [
	finalSize := anInteger
]

{ #category : #printing }
BtFile >> printOn: aStream [
	aStream nextPutAll: reference asString.
]

{ #category : #accessing }
BtFile >> reference [
	^ reference
]

{ #category : #accessing }
BtFile >> reference: aFileReference [
	reference := aFileReference
]
