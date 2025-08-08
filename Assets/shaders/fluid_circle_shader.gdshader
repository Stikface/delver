// adaptation of Mirza Beig's shader
// https://www.shadertoy.com/view/Ds3fRN

shader_type canvas_item;

uniform float fill_value : hint_range(0.0, 1.0) = 0.5;
uniform float ringWidth = 0.1;
uniform float innerCircleRadiusOffset = 0.05;
uniform float fill_oscillation_frequency = 1.0;
uniform float fill_oscillation_amplitude = 0.05; //this moves the whole fill
uniform float wave_frequency = 2.0;
uniform float wave_amplitude = 0.05;
uniform float animatedVerticalBandStrength = 0.125;

uniform vec3 ringColor : source_color = vec3(1.0);
uniform vec3 frontFillInnerColor : source_color = vec3(1.0);
uniform vec3 frontFillOuterColor : source_color = vec3(0.5);
uniform float frontFillInnerStrength : hint_range(0.0, 10.0) = 4.0;
uniform vec3 backFillColor : source_color = vec3(0.2);
uniform vec3 fresnelColor : source_color = vec3(1.0);

void fragment() {
	// Called for every pixel the material is visible on.
	//scale the whole thing to fit inside the UVs
    vec2 uv = (-UV / vec2(0.5,0.5)) + vec2(1,1);
	
	float circleSDF = length(uv);
	
	float oneMinusRingWidth = 1.0 - ringWidth;
	
	float circleA = step(circleSDF,1.0);
	float circleB = step(circleSDF,oneMinusRingWidth);
	float ring = circleA - circleB;
	
	float fillMaskCircle = step(circleSDF, oneMinusRingWidth - innerCircleRadiusOffset);
	
	// Centered fill progress.
    //  -1.0 = bottom, 0.0 = center, 1.0 = top.
    float fillProgress = (fill_value - 0.5) * 2.0;
    fillProgress -= sin((TIME * fill_oscillation_frequency) * PI) * fill_oscillation_amplitude;
	
	const float waveAnimation = 2.0;
	float frontWavePhase = (TIME * waveAnimation) + uv.x;
	float backWavePhase = (TIME * -waveAnimation) + uv.x;
	frontWavePhase *= wave_frequency;
    backWavePhase *= wave_frequency;
	
	float verticalBand = sin (uv.x + (PI * 0.5) - 0.3);
	verticalBand = smoothstep(0.1,0.9,verticalBand);
	float animatedVerticalBand = verticalBand * animatedVerticalBandStrength;
	animatedVerticalBand *= sin (TIME * wave_frequency);
	
	float frontWaves = sin(frontWavePhase) * wave_amplitude;
	float backWaves = sin(frontWavePhase + PI) * wave_amplitude;
	frontWaves += animatedVerticalBand;
	backWaves -= animatedVerticalBand;
	
	float frontFill = step(uv.y, frontWaves + fillProgress);
    float backFill = step(uv.y, backWaves + fillProgress);
	frontFill *= fillMaskCircle;
	backFill *= fillMaskCircle;
	backFill = clamp(backFill - frontFill, 0.0, 1.0);
	float fill = frontFill + backFill;
	float fillMask = 1.0 - fill;
    fillMask *= fillMaskCircle;
	
	// fresnel
	float fresnelOffset = (innerCircleRadiusOffset);
	float fresnel = (circleSDF + fresnelOffset) * fillMask;
	const float fresnelPower = 4.0;
	fresnel = clamp(pow(fresnel, fresnelPower), 0.0, 1.0);
	
	float frontFillFresnel = (circleSDF + fresnelOffset) * (1.0 - fillMask);
	frontFillFresnel = clamp(pow(frontFillFresnel, frontFillInnerStrength), 0.0, 1.0);
	vec3 frontFillColor = mix(frontFillInnerColor,frontFillOuterColor,frontFillFresnel);
	
	float mask = ring + fill + fresnel;

	vec3 rgb =
		(ring * ringColor) +
		(frontFill * frontFillColor) +
		(backFill * backFillColor) +
		(fresnel * fresnelColor);
		
	COLOR = vec4(rgb, mask);
	
}