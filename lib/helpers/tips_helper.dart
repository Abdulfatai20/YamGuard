Map<String, String> getTipsByFeel(String weather) {
  switch (weather.toLowerCase()) {
    case 'very sunny':
      return {
        'advice': 'Good day to dry or harvest yams.',
        'action': 'No planting today. Check your yam store.',
      };
    case 'sunny':
      return {
        'advice': 'Sun helps yams grow well.',
        'action': 'Check farm and add manure if needed.',
      };
    case 'partly sunny':
      return {
        'advice': 'Small sun helps yams grow well.',
        'action': 'Check farm and add manure if needed.',
      };
    case 'mostly cloudy':
      return {
        'advice': 'Cloudy skies, but yams will do just fine.',
        'action': 'Check for rot and remove weeds.',
      };
    case 'light rain':
      return {
        'advice': 'Soft rain helps yam to grow.',
        'action': 'You can plant, but make sure water drains.',
      };
    case 'rainy':
    case 'heavy rain':
      return {
        'advice': 'Too much rain can spoil stored yams.',
        'action': 'Stay off the farm. Check yam barns for leaks.',
      };
    case 'stormy rain':
      return {
        'advice': 'Flood may damage your farm.',
        'action': 'Move yams to dry, safe place.',
      };
    case 'windy':
    case 'stormy winds':
      return {
        'advice': 'Strong wind can break yam vines.',
        'action': 'Tie vines and support weak sticks.',
      };
    case 'harmattan':
      return {
        'advice': 'Dry air is good for yam storage.',
        'action': 'Cover yams to stop them from drying too much.',
      };
    default:
      return {
        'advice': 'The weather looks normal.',
        'action': 'Keep farming as usual.',
      };
  }
}
