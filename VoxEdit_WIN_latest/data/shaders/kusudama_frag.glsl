#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec3 vertNormal;
varying vec3 vertWorldNormal;

 // up to 10 cones (represented by 30 4d vectors)
uniform vec4 coneSequence[30];
uniform vec4 coneEdgeSequence[30];
uniform int coneCount; 

uniform vec4 allowedColor;
uniform vec4 forbiddenColor;
uniform bool renderEdges;
uniform vec4 edgeColor;

// returns 1 if normalDir is beyond (cone.a) radians from cone.rgb
// returns 0 if normalDir is within (cone.a + boundaryWidth) radians from cone.rgb
// return -1 if normalDir is less than (cone.a) radians from cone.rgb
int isInCone(in vec3 normalDir, in vec4 cone, in float boundaryWidth)
{
	float arcDistToCone = acos(dot(normalDir, cone.rgb));
	if (arcDistToCone > cone.a + (boundaryWidth * 0.5f))
		return 1;
	if (arcDistToCone < cone.a - (boundaryWidth * 0.5f))
		return -1;
	return 0;
}

bool isBetweenCones(in vec3 normalDir, in vec4 tangent1, in vec4 cone1, in vec4 tangent2, in vec4 cone2)
{
	vec3 c1xc2 = cross(cone1.xyz, cone2.xyz);
	float c1c2dir = dot(normalDir, c1xc2);

	if (c1c2dir < 0.0)
	{
		vec3 c1xt1 = cross(cone1.xyz, tangent1.xyz);
		vec3 t1xc2 = cross(tangent1.xyz, cone2.xyz);
		float c1t1dir = dot(normalDir, c1xt1);
		float t1c2dir = dot(normalDir, t1xc2);

		return (c1t1dir > 0.0 && t1c2dir > 0.0);
	}

	vec3 t2xc1 = cross(tangent2.xyz, cone1.xyz);
	vec3 c2xt2 = cross(cone2.xyz, tangent2.xyz);
	float t2c1dir = dot(normalDir, t2xc1);
	float c2t2dir = dot(normalDir, c2xt2);

	return (c2t2dir > 0.0 && t2c1dir > 0.0);
}

// determines the current draw condition based on the desired draw condition in the setToArgument
// -3 = disallowed entirely;
// -2 = disallowed and on tangentCone boundary
// -1 = disallowed and on controlCone boundary
// 0 =  allowed and empty;
// 1 =  allowed and on controlCone boundary
// 2  = allowed and on tangentCone boundary
int getAllowabilityCondition(in int currentCondition, in int setTo)
{
	if((currentCondition == -1 || currentCondition == -2) && setTo >= 0)
		return currentCondition *= -1;
	else if (currentCondition == 0 && (setTo == -1 || setTo == -2))
		return setTo *=-2;
	return max(currentCondition, setTo);
}

bool isAllowed(in vec3 normalDir,  in int coneCount, in vec4[30] cones, in float boundaryWidth)
{
	int currentCondition = -3;
	if (coneCount == 1)
	{
		vec4 cone = cones[0];
		int inCone = isInCone(normalDir, cone, boundaryWidth);
		inCone = inCone == 0 ? -1 : inCone < 0 ? 0 : -3;
		currentCondition = getAllowabilityCondition(currentCondition, inCone);
		if (currentCondition >= 0)
			return true;
	}
	else
	{
		for (int i = 0; i < coneCount; i++)
		{
			int idx = i * 3;
			vec4 cone1 = cones[idx];
			vec4 tangent1 = cones[idx + 1];
			vec4 tangent2 = cones[idx + 2];
			vec4 cone2 = cones[idx + 3];

			int inCone1 = isInCone(normalDir, cone1, boundaryWidth);

			inCone1 = inCone1 == 0 ? -1 : inCone1 < 0 ? 0 : -3;
			currentCondition = getAllowabilityCondition(currentCondition, inCone1);

			int inCone2 = isInCone(normalDir, cone2, boundaryWidth);
			inCone2 =  inCone2 == 0 ? -1 : inCone2  < 0 ? 0 : -3;
			currentCondition = getAllowabilityCondition(currentCondition, inCone2);

			int inTan1 = isInCone(normalDir, tangent1, boundaryWidth);
			int inTan2 = isInCone(normalDir, tangent2, boundaryWidth);

			bool inIntercone = false;
			if (inTan1 < 1.0f || inTan2  < 1.0f)
			{
				inTan1 =  inTan1 == 0 ? -2 : -3;
				currentCondition = getAllowabilityCondition(currentCondition, inTan1);
				inTan2 =  inTan2 == 0 ? -2 : -3;
				currentCondition = getAllowabilityCondition(currentCondition, inTan2);
			}
			else
			{
				inIntercone = isBetweenCones(normalDir, tangent1, cone1, tangent2, cone2);
				int interconeCondition = inIntercone ? 0 : -3;

				// draws long distance, might be useful someday
				//int interconeCondition = inIntercone && (inTan1 > 0 || inTan2 > 0) ? -3 : 0;

				currentCondition = getAllowabilityCondition(currentCondition, interconeCondition);
				inIntercone = inIntercone && !(inTan1 > 0 || inTan2 > 0);
			}
			if (currentCondition >= 0)
				return true;
		}
	}
	return false;
}

void main()
{
	vec3 normalDir = normalize(vertNormal);
	if (renderEdges)
	{
		if (isAllowed(normalDir, coneCount, coneSequence, 0.02f))
		{
			if (isAllowed(normalDir, coneCount, coneEdgeSequence, 0.02f) == false)
			{
				if (vertWorldNormal.z < 0.0)
					gl_FragColor = edgeColor * 0.75f;
				else
					gl_FragColor = edgeColor;
			}
			else
				discard;
		}
		else
			discard;
	}
	else if (isAllowed(normalDir, coneCount, coneSequence, 0.02f))
	{
		if (vertWorldNormal.z < 0.0)
			gl_FragColor = allowedColor * 0.25f;
		else
			gl_FragColor = allowedColor;
	}
	else
		gl_FragColor = forbiddenColor;
}
