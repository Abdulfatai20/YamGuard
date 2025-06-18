Map<String, String> getTipsByFeel(String weather) {
  switch (weather.toLowerCase()) {
    case 'very sunny':
      return {
        'advice': 'Very hot sun today! Good for drying yam. Hot sun stops yam from going bad.',
        'action': 'Harvest ready yam and put in sun to dry. Check old yam for water. Don\'t plant today - ground too hot.',
      };
    
    case 'mostly sunny':
      return {
        'advice': 'Good sun today. Yam plants grow well in this sun.',
        'action': 'Remove weeds around yam. Add compost if you have. Check if yam needs water. Harvest any ready yam.',
      };
    
    case 'partly sunny':
      return {
        'advice': 'Sun and small clouds. Very good for yam plants. Not too hot.',
        'action': 'Look for insects on yam leaves. Add fertilizer if you have. Good day to work on farm.',
      };
      
    case 'partly cloudy':
      return {
        'advice': 'Small clouds in sky. Good for yam. Plants not too hot.',
        'action': 'Check yam leaves for insects. Remove weeds. Check if yam sticks need fixing.',
      };
    
    case 'mostly cloudy':
      return {
        'advice': 'Many clouds today. Good for yam but watch for sickness on leaves.',
        'action': 'Look for spots on yam leaves. Remove sick plants. Make sure air moves around plants.',
      };
    
    case 'cloudy':
      return {
        'advice': 'Sky covered with clouds. Can cause yam leaves to get sick.',
        'action': 'Check yam leaves for disease. Don\'t water unless ground is dry. Check water flows away.',
      };
    
    case 'light rain':
      return {
        'advice': 'Small rain is good for yam. Gives water without flooding.',
        'action': 'Good time to plant yam pieces. Check water goes away well. No need to water today.',
      };
    
    case 'rainy':
      return {
        'advice': 'Rain helps yam grow but makes farm muddy.',
        'action': 'Don\'t walk on wet farm - you spoil soil. Check water flows away. Check stored yam for water.',
      };
    
    case 'heavy rain':
      return {
        'advice': 'Too much rain! Can make yam rot and wash away soil.',
        'action': 'Don\'t work on farm. Check yam store for leaks. Clear blocked water ways. Watch for washing away.',
      };
    
    case 'stormy rain':
      return {
        'advice': 'Very bad rain and wind! Can flood farm and destroy yam.',
        'action': 'Move harvested yam to high, dry place. Check roof for holes. Stay inside to be safe.',
      };
    
    case 'windy':
      return {
        'advice': 'Strong wind can break yam vines and knock down sticks.',
        'action': 'Make vine supports strong. Tie loose vines tight. Check for broken sticks.',
      };
    
    case 'stormy winds':
      return {
        'advice': 'Very strong wind! Can destroy yam farm and damage storage.',
        'action': 'Keep all farm tools safe. Make yam storage strong. Fix broken sticks now.',
      };
    
    case 'harmattan':
      return {
        'advice': 'Dry harmattan wind. Very good for drying yam but can make growing plants dry.',
        'action': 'Best time to dry harvested yam. Cover stored yam so not too dry. Water young plants if ground very dry.',
      };
    
    default:
      return {
        'advice': 'Normal weather for your area.',
        'action': 'Do normal farm work. Check yam growth and storage as usual.',
      };
  }
}