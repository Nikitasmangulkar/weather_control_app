import 'package:web/web.dart' as web;
import '../firebase_backend.dart';


const firebaseApiKey  = 'AIzaSyDIp4BwqfynBXIPhrZUKV38dxjOg475J6s';
const firebaseProject = 'weather-control-webapp';

late final FirebaseBackend backend;



void main() {
  print('Weather Control App starting...');
  
  // Initialize UI controls
  setupControls();
  updateDisplay();
}

void setupControls() {
  // Temperature control
  final tempSlider = web.document.querySelector('#temperature') as web.HTMLInputElement;
  final tempValue = web.document.querySelector('#temp-value') as web.HTMLSpanElement;
  
  tempSlider.onInput.listen((event) {
    tempValue.text = '${tempSlider.value}°C';
  });

  // Humidity control
  final humiditySlider = web.document.querySelector('#humidity') as web.HTMLInputElement;
  final humidityValue = web.document.querySelector('#humidity-value') as web.HTMLSpanElement;
  
  humiditySlider.onInput.listen((event) {
    humidityValue.text = '${humiditySlider.value}%';
  });

  // Wind control
  final windSlider = web.document.querySelector('#wind') as web.HTMLInputElement;
  final windValue = web.document.querySelector('#wind-value') as web.HTMLSpanElement;
  
  windSlider.onInput.listen((event) {
    windValue.text = '${windSlider.value} km/h';
  });

  // Apply changes button
  final applyButton = web.document.querySelector('#apply-changes') as web.HTMLButtonElement;
  applyButton.onClick.listen((event) {
    applyWeatherChanges();
  });
}

void applyWeatherChanges() {
  final temp = (web.document.querySelector('#temperature') as web.HTMLInputElement).value;
  final humidity = (web.document.querySelector('#humidity') as web.HTMLInputElement).value;
  final wind = (web.document.querySelector('#wind') as web.HTMLInputElement).value;
  final weatherType = (web.document.querySelector('#weather-type') as web.HTMLSelectElement).value;

  // Update current status display
  (web.document.querySelector('#current-temp') as web.HTMLSpanElement).text = '$temp°C';
  (web.document.querySelector('#current-humidity') as web.HTMLSpanElement).text = '$humidity%';
  (web.document.querySelector('#current-wind') as web.HTMLSpanElement).text = '$wind km/h';
  (web.document.querySelector('#current-weather') as web.HTMLSpanElement).text = 
      weatherType[0].toUpperCase() + weatherType.substring(1);

  // Update background based on weather type
  updateBackground(weatherType);
  
  // Here you would typically save to Firebase
  saveToFirebase(temp, humidity, wind, weatherType);
  
  print('Weather updated: $temp°C, $humidity%, $wind km/h, $weatherType');
}

void updateBackground(String weatherType) {
  final body = web.document.body!;
  
  switch(weatherType) {
    case 'sunny':
      body.style.background = 'linear-gradient(135deg, #f7b733, #fc4a1a)';
      break;
    case 'cloudy':
      body.style.background = 'linear-gradient(135deg, #bdc3c7, #2c3e50)';
      break;
    case 'rainy':
      body.style.background = 'linear-gradient(135deg, #4b6cb7, #182848)';
      break;
    case 'snowy':
      body.style.background = 'linear-gradient(135deg, #e6ddd4, #d5d4d0)';
      break;
    case 'stormy':
      body.style.background = 'linear-gradient(135deg, #2c3e50, #34495e)';
      break;
    default:
      body.style.background = 'linear-gradient(135deg, #74b9ff, #0984e3)';
  }
}

void saveToFirebase(String temp, String humidity, String wind, String weatherType) {
  // Firebase integration placeholder - will be implemented when Firebase is properly set up
  final data = {
    'temperature': temp,
    'humidity': humidity,
    'windSpeed': wind,
    'weatherType': weatherType,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  print('Weather data prepared for Firebase: $data');
  // TODO: Implement Firebase SDK integration for web
}

void updateDisplay() {
  print('Weather Control Center initialized successfully!');
}






Future<void> main() async {
  backend = FirebaseBackend(apiKey: firebaseApiKey, projectId: firebaseProject);


  await backend.signInAnonymously();


  final weather = await backend.getWeather();
  _renderWeather(weather);

  
  querySelector('#applyButton')!.onClick.listen((_) async {
    final temp = (querySelector('#tempRange') as InputElement).valueAsNumber!.toInt();
    final hum  = (querySelector('#humidityRange') as InputElement).valueAsNumber!.toInt();
    final wind = (querySelector('#windRange') as InputElement).valueAsNumber!.toInt();
    final type = (querySelector('#weatherType') as SelectElement).value ?? 'Sunny';

    await backend.updateWeather({
      'temperature': temp,
      'humidity': hum,
      'windSpeed': wind,
      'type': type,
      'updatedBy': backend.uid,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  });

void _renderWeather(Map<String, dynamic> w) {
  querySelector('#tempOut')!.text = '${w['temperature'] ?? 20}°C';
  querySelector('#humOut')!.text  = '${w['humidity'] ?? 50}%';
  querySelector('#windOut')!.text = '${w['windSpeed'] ?? 10} km/h';
  querySelector('#typeOut')!.text = (w['type'] ?? 'Sunny').toString();
}
