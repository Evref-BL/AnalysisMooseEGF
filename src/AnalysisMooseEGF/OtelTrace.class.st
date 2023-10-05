Class {
	#name : #OtelTrace,
	#superclass : #Object,
	#instVars : [
		'parentID',
		'spanID',
		'traceID',
		'timestamp',
		'famixMethodCandidates',
		'methodSignature',
		'order'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #accessing }
OtelTrace >> famixMethodCandidates [

	^ famixMethodCandidates
]

{ #category : #accessing }
OtelTrace >> famixMethodCandidates: anObject [

	famixMethodCandidates := anObject
]

{ #category : #initialization }
OtelTrace >> initialize [ 	
	famixMethodCandidates := OrderedCollection new.
]

{ #category : #accessing }
OtelTrace >> methodSignature [

	^ methodSignature
]

{ #category : #accessing }
OtelTrace >> methodSignature: anObject [

	methodSignature := anObject
]

{ #category : #accessing }
OtelTrace >> order [

	^ order
]

{ #category : #accessing }
OtelTrace >> order: anObject [

	order := anObject
]

{ #category : #accessing }
OtelTrace >> parentID [

	^ parentID
]

{ #category : #accessing }
OtelTrace >> parentID: anObject [

	parentID := anObject
]

{ #category : #'as yet unclassified' }
OtelTrace >> refineCandidates [

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
OtelTrace >> spanID [

	^ spanID
]

{ #category : #'as yet unclassified' }
OtelTrace >> spanID: aString [

	spanID := aString. 
]

{ #category : #accessing }
OtelTrace >> timestamp [

	^ timestamp
]

{ #category : #accessing }
OtelTrace >> timestamp: anObject [

	timestamp := anObject
]

{ #category : #accessing }
OtelTrace >> traceID [

	^ traceID
]

{ #category : #accessing }
OtelTrace >> traceID: anObject [

	traceID := anObject
]
