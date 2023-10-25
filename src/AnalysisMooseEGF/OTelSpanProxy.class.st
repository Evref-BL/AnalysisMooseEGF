Class {
	#name : #OTelSpanProxy,
	#superclass : #OTelSpan,
	#instVars : [
		'famixOTelSpan'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'instance creation' }
OTelSpanProxy class >> newFrom: aFamixOTelSpanModel [
	^ OTelSpanProxy new famixOTelSpan: aFamixOTelSpanModel.
	
]

{ #category : #accessing }
OTelSpanProxy >> famixOTelSpan [
	^ famixOTelSpan.
]

{ #category : #accessing }
OTelSpanProxy >> famixOTelSpan: aFamixOTelSpanModel [

	famixOTelSpan ifNil: [ famixOTelSpan := aFamixOTelSpanModel ]. 
]

{ #category : #initialization }
OTelSpanProxy >> initialize [ 
	famixOTelSpan := nil. 
]

{ #category : #accessing }
OTelSpanProxy >> methodSignature [

	^ famixOTelSpan tags at: 'drit.method' ifAbsent: nil
]

{ #category : #accessing }
OTelSpanProxy >> order [

	^ famixOTelSpan tags at: 'drit.order' ifAbsent: nil
]

{ #category : #accessing }
OTelSpanProxy >> parentID [

	^ famixOTelSpan parent ifNotNil: [ famixOTelSpan parent id ] ifNil: [ nil ].
]

{ #category : #accessing }
OTelSpanProxy >> spanID [

	^ famixOTelSpan id
]

{ #category : #accessing }
OTelSpanProxy >> stackcall [

	^ famixOTelSpan tags at: 'drit.stackcall' ifAbsent: nil
]

{ #category : #accessing }
OTelSpanProxy >> threadID [

	^ famixOTelSpan tags at: 'thread.id' ifAbsent: nil
]

{ #category : #accessing }
OTelSpanProxy >> timestamp [

	^ famixOTelSpan timestamp 
]

{ #category : #accessing }
OTelSpanProxy >> traceID [

	^ famixOTelSpan trace ifNotNil: [famixOTelSpan trace id ] ifNil: [nil]. 
]
