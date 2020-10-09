#version 330 core

struct Material {
	sampler2D diffuse;
	sampler2D specular;
	float shininess;
};

struct DirLight {
	vec3 direction;

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};

struct PointLight {
	vec3 position;

	float constant;
	float linear;
	float quadratic;

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;
};
#define NR_POINT_LIGHTS 4

struct Light {
	//vec3 Position; //Used for the typical specular highlighting chapter
	vec3 direction; //Used for directional lights and spotlights
	vec3 position; //Used for spotlights and directional lights
	float cutOff;	//innerCutOff

	float outerCutOff; //outerCutOff

	vec3 ambient;
	vec3 diffuse;
	vec3 specular;

	float constant;
	float linear;
	float quadratic;
};


in vec2 TexCoords;
in vec3 Normal;
in vec3 FragPos;

out vec4 FragColor;

uniform Material material;
uniform Light light;
uniform vec3 lightPos;
uniform vec3 lightColor;
uniform vec3 objectColor;
uniform vec3 viewPos;
uniform DirLight dirLight;
uniform PointLight pointLights[NR_POINT_LIGHTS];

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

void main()
{

	//---------SKIP TO THE BOTTOM TO SEE UNCOMMENTED CODE!---------

	/*
	//Diffuse:
	vec3 norm = normalize(-light.direction);
	vec3 lightDir = normalize(lightPos - FragPos);
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = diff * light.diffuse * texture(material.diffuse, TexCoords).rgb;

	//Ambient:
	float ambientStrength = 0.1;
	vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;

	//Specular:
	float specularStrength = 0.5;
	vec3 viewDir = normalize(viewPos - FragPos);
	vec3 reflectDir = reflect(-lightDir, norm);
	//Now calculate the specular component:
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
	vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;

	vec3 result = (ambient + diffuse + specular) * objectColor;
	*/

	//---------END OF COMMENTED OUT CODE!---------

	//---------MORE COMMENTED OUT CODE!-----------

	/*
	//Ambient
	vec3 ambient = light.ambient * texture(material.diffuse, TexCoords).rgb;

	//Diffuse
	vec3 norm = normalize(Normal);
	vec3 lightDir = normalize(light.position - FragPos);
	float diff = max(dot(norm, lightDir), 0.0);
	vec3 diffuse = diff * light.diffuse * texture(material.diffuse, TexCoords).rgb;

	//Specular
	vec3 viewDir = normalize(viewPos - FragPos);
	vec3 reflectDir = reflect(-lightDir, norm);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
	vec3 specular = light.specular * spec * texture(material.specular, TexCoords).rgb;


	float distance = length(light.position - FragPos);
	float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));

	

	float theta = dot(lightDir, normalize(-light.direction));
	float epsilon = light.cutOff - light.outerCutOff;
	float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
	diffuse *= intensity;
	specular *= intensity;
	

	vec3 result;


	ambient *= attenuation;
	diffuse *= attenuation;
	specular *= attenuation;

	result = ambient + diffuse + specular;
	FragColor = vec4(result, 1.0);
	*/

	//---------END OF COMMENTED OUT CODE!---------


	//---------BEGIN NEW CODE!---------

	//Properties:
	vec3 norm = normalize(Normal);
	vec3 viewDir = normalize(viewPos - FragPos);

	//Directional lighting first (by choice, I think):
	vec3 result = CalcDirLight(dirLight, norm, viewDir);
	//Point lights next:
	for(int i = 0; i < NR_POINT_LIGHTS; i++)
		result += CalcPointLight(pointLights[i], norm, FragPos, viewDir);
	//Spot Light
	//result += CalcSpotLight(spotLight, norm, FragPos, viewDir);

	FragColor = vec4(result, 1.0);
}

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir)
{
	vec3 lightDir = normalize(-light.direction);
	//Diffuse shading:
	float diff = max(dot(normal, lightDir), 0.0);
	//Specular shading
	vec3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);

	//Combine it all
	vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
	vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
	vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
	return (ambient + diffuse + specular);
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
	vec3 lightDir = normalize(light.position - fragPos);
	//Diffuse shading
	float diff = max(dot(normal, lightDir), 0.0);
	//Specular shading
	vec3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
	//Attenuation
	float distance = length(light.position - fragPos);
	float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));

	//Combine it all
	vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
	vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));
	vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
	ambient *= attenuation;
	diffuse *= attenuation;
	specular *= attenuation;
	return (ambient + diffuse + specular);
}