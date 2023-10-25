Class {
	#name : #OTelSpan,
	#superclass : #Object,
	#instVars : [
		'parentID',
		'spanID',
		'traceID',
		'timestamp',
		'famixMethodCandidates',
		'methodSignature',
		'order',
		'stackcall',
		'threadID'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #accessing }
OTelSpan >> famixMethodCandidates [

	^ famixMethodCandidates
]

{ #category : #accessing }
OTelSpan >> famixMethodCandidates: anObject [

	famixMethodCandidates := anObject
]

{ #category : #initialization }
OTelSpan >> initialize [ 	
	famixMethodCandidates := OrderedCollection new.
]

{ #category : #accessing }
OTelSpan >> methodSignature [

	^ methodSignature
]

{ #category : #accessing }
OTelSpan >> methodSignature: anObject [

	methodSignature := anObject
]

{ #category : #accessing }
OTelSpan >> order [

	^ order
]

{ #category : #accessing }
OTelSpan >> order: anObject [

	order := anObject
]

{ #category : #accessing }
OTelSpan >> parentID [

	^ parentID
]

{ #category : #accessing }
OTelSpan >> parentID: anObject [

	parentID := anObject
]

{ #category : #'as yet unclassified' }
OTelSpan >> refineCandidates [

	| candidates filtered parms |

	
	candidates := self famixMethodCandidates.
	filtered := OrderedCollection new.

	"check for the same number of parameter"
	parms := (methodSignature
		          copyFrom: (methodSignature indexOf: $() + 1
		          to: (methodSignature indexOf: $)) - 1) splitOn: ','.
	filtered := candidates select: [ :m | 
		            m numberOfParameters = parms size ].

	filtered := filtered select: [ :m | 
		            | mtdParms check |
		            check := true.
		            mtdParms := (m mooseNameWithDots
			                         copyFrom:
			                         (m mooseNameWithDots indexOf: $() + 1
			                         to: (m mooseNameWithDots indexOf: $)) - 1) 
			                        splitOn: ','.
		            1 to: parms size do: [ :i | 
			            | pc pt |
			            pc := (mtdParms at: i) replaceAllRegex: '<.*>' with: ''.
			            pt := (parms at: i) replaceAllRegex: '<.*>' with: ''.

			            ((pc includesSubstring: pt) or: [ 
				             pt includesSubstring: pc ]) ifFalse: [ 
				            check := false ] ].
		            check ].


	filtered isEmpty ifFalse: [ self famixMethodCandidates: filtered ]
]

{ #category : #accessing }
OTelSpan >> spanID [

	^ spanID
]

{ #category : #'as yet unclassified' }
OTelSpan >> spanID: aString [

	spanID := aString. 
]

{ #category : #setter }
OTelSpan >> stackcall [

	^ stackcall 
]

{ #category : #setter }
OTelSpan >> stackcall: aString [ 
	stackcall := aString
]

{ #category : #setter }
OTelSpan >> threadID [

	^ threadID
]

{ #category : #setter }
OTelSpan >> threadID: anUndefinedObject [ 
	threadID := anUndefinedObject
]

{ #category : #accessing }
OTelSpan >> timestamp [

	^ timestamp
]

{ #category : #accessing }
OTelSpan >> timestamp: anObject [

	timestamp := anObject
]

{ #category : #accessing }
OTelSpan >> traceID [

	^ traceID
]

{ #category : #accessing }
OTelSpan >> traceID: anObject [

	traceID := anObject
]
