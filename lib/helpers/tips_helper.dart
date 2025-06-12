Map<String, String> getTipsByFeel(String weather) {
  switch (weather.toLowerCase()) {
    case 'very sunny':
      return {
        'advice': 'Perfect drying weather! Strong sun helps cure harvested yams and prevents rot.',
        'action': 'Harvest mature yams and spread them in sun to dry. Check stored yams for moisture. Avoid planting - soil may be too hot.',
      };
    
    case 'mostly sunny':
      return {
        'advice': 'Excellent growing conditions. Strong sun promotes healthy yam vine growth.',
        'action': 'Good day for weeding and adding organic manure. Check if soil needs watering. Harvest any ready yams.',
      };
    
    case 'partly sunny':
      return {
        'advice': 'Good balance of sun and clouds. Yam vines grow well without stress from intense heat.',
        'action': 'Check farm for pests and diseases. Apply fertilizer if needed. Good day for routine farm maintenance.',
      };
      
    case 'partly cloudy':
      return {
        'advice': 'Mild conditions are good for yam growth. Less water stress on plants.',
        'action': 'Inspect vines for pest damage. Remove weeds that compete for nutrients. Check staking needs.',
      };
    
    case 'mostly cloudy':
      return {
        'advice': 'Cloudy skies reduce heat stress but may increase humidity and disease risk.',
        'action': 'Check for fungal diseases on leaves. Remove infected plants. Ensure good air circulation around vines.',
      };
    
    case 'cloudy':
      return {
        'advice': 'Overcast conditions can encourage fungal problems but reduce plant stress.',
        'action': 'Monitor for leaf spot and other diseases. Avoid watering unless soil is dry. Check drainage.',
      };
    
    case 'light rain':
      return {
        'advice': 'Gentle rain provides good moisture for yam growth without waterlogging.',
        'action': 'Good time for planting yam setts. Check that water drains well. No need to water manually.',
      };
    
    case 'rainy':
      return {
        'advice': 'Moderate rain helps yam growth but creates muddy conditions.',
        'action': 'Stay off wet farm to avoid soil compaction. Check drainage channels. Monitor stored yams for moisture.',
      };
    
    case 'heavy rain':
      return {
        'advice': 'Too much water can cause yam rot and soil erosion. Risk of waterlogging.',
        'action': 'Avoid farm work. Check yam storage for leaks. Clear blocked drainage. Watch for soil erosion.',
      };
    
    case 'stormy rain':
      return {
        'advice': 'Heavy storms can flood farms and damage crops. Risk of losing entire harvest.',
        'action': 'Move harvested yams to high, dry ground. Check building roofs for leaks. Stay indoors for safety.',
      };
    
    case 'windy':
      return {
        'advice': 'Strong winds can break yam vines and damage staking systems.',
        'action': 'Reinforce vine supports and stakes. Tie loose vines securely. Check for broken branches.',
      };
    
    case 'stormy winds':
      return {
        'advice': 'Very strong winds can destroy entire yam farms and damage storage buildings.',
        'action': 'Secure all farm equipment. Reinforce yam storage buildings. Check and repair damaged stakes immediately.',
      };
    
    case 'harmattan':
      return {
        'advice': 'Dry harmattan air is excellent for drying and storing yams but can stress growing plants.',
        'action': 'Perfect time to dry harvested yams. Cover stored yams to prevent over-drying. Water young plants if soil is very dry.',
      };
    
    default:
      return {
        'advice': 'Weather conditions are normal for your area.',
        'action': 'Continue regular farm activities. Check yam growth and storage as usual.',
      };
  }
}

