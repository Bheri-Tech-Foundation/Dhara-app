#!/bin/bash
# Quick script to run Dhara web app in development mode

echo "🚀 Starting Dhara Web Development Server..."
echo ""
echo "📋 Configuration:"
echo "   - Port: 5000"
echo "   - Backend: https://project.iith.ac.in/bheri/api/"
echo "   - Google OAuth: Configured"
echo ""
echo "🌐 Once started, open: http://localhost:5000"
echo ""
echo "💡 Press 'r' to hot reload, 'R' to hot restart, 'q' to quit"
echo ""

flutter run -d chrome --web-port=5000







