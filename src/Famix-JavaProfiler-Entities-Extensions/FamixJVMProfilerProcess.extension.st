Extension { #name : #FamixJVMProfilerProcess }

{ #category : #'*Famix-JavaProfiler-Entities-Extensions' }
FamixJVMProfilerProcess >> getMethodIdentifier [
	|from to res|
	"
	to := ((self rawMthSignature indexOf: $( ifAbsent: self rawMthSignature size )). 
	res := self rawMthSignature copyFrom: 1 to: to. 
	from := ((res lastIndexOf: $. ifAbsent: 1 )).
	to > from ifTrue: [ ^ res copyFrom: from to: to.  ] ifFalse: [ ^ self rawMthSignature ]."
	^ self rawMthSignature
]

{ #category : #'*Famix-JavaProfiler-Entities-Extensions' }
FamixJVMProfilerProcess >> mooseNameOn: aStream [

	aStream nextPutAll: (self getMethodIdentifier).
]

{ #category : #'*Famix-JavaProfiler-Entities-Extensions' }
FamixJVMProfilerProcess >> printOn: aStream [

	aStream << 'a JVMProcess '.
	aStream << ': '.
	(self getMethodIdentifier) printOn: aStream.
]
