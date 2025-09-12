#!/usr/bin/env python3
"""
HireIQ Environment Configuration Helper
This script helps generate required configuration values for deployment
"""

import secrets
import string

def generate_django_secret_key():
    """Generate a secure Django secret key"""
    chars = string.ascii_letters + string.digits + '!@#$%^&*(-_=+)'
    return ''.join(secrets.choice(chars) for _ in range(50))

def main():
    print("=" * 60)
    print("   HireIQ Environment Configuration Helper")
    print("=" * 60)
    print()
    
    print("🔑 Generated Django Secret Key:")
    print(f"SECRET_KEY={generate_django_secret_key()}")
    print()
    
    print("📋 Required External Services Setup:")
    print()
    
    print("1. 🗄️  MongoDB Atlas:")
    print("   • Go to: https://www.mongodb.com/cloud/atlas")
    print("   • Create free cluster")
    print("   • Create database user")
    print("   • Get connection string")
    print()
    
    print("2. 🔐 Google OAuth:")
    print("   • Go to: https://console.cloud.google.com/")
    print("   • Create OAuth 2.0 credentials")
    print("   • Get Client ID and Secret")
    print()
    
    print("3. 📧 Gmail App Password:")
    print("   • Enable 2FA on Gmail")
    print("   • Generate App Password")
    print()
    
    print("4. 🤖 Groq API:")
    print("   • Go to: https://groq.com/")
    print("   • Get API key")
    print()
    
    print("📝 Next Steps:")
    print("   1. Set up the external services above")
    print("   2. Create .env files using the templates")
    print("   3. Upload to EC2 and run deployment script")
    print()
    
    print("🚀 Deployment Commands:")
    print("   scp -r -i 'keypair.pem' . ubuntu@EC2_IP:/opt/hireiq/")
    print("   ssh -i 'keypair.pem' ubuntu@EC2_IP")
    print("   cd /opt/hireiq && ./deployment/deploy.sh")
    print()

if __name__ == "__main__":
    main()