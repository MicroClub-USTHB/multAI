import asyncio
import json
import urllib.error
import urllib.request

from app.core.config import settings
from app.core.logger import logger


class EmailSender:
    @staticmethod
    def _error_code(body: bytes) -> str:
        """The provider's error code only: the body can echo the recipient."""
        try:
            code = json.loads(body).get("code")
        except (ValueError, AttributeError):
            return "unknown"
        return code if isinstance(code, str) else "unknown"

    @staticmethod
    async def send_otp_email(to_email: str, otp: str) -> bool:
        if not settings.EMAIL_HTTP_API_KEY:
            if settings.environment == "dev":
                logger.warning(
                    "EMAIL_HTTP_API_KEY is not set. Skipping email sending."
                )
                # In development without a key, just log the OTP
                logger.info("MOCK EMAIL to %s: Your OTP is %s", to_email, otp)
                return True
            logger.error("EMAIL_HTTP_API_KEY is not set: cannot send the OTP email")
            return False
        if not settings.EMAIL_FROM:
            logger.error("EMAIL_FROM is not set: cannot send the OTP email")
            return False

        url = f"{settings.EMAIL_HTTP_BASE_URL.rstrip('/')}/messages"
        headers = {
            "Authorization": f"Bearer {settings.EMAIL_HTTP_API_KEY}",
            "Content-Type": "application/json",
            "User-Agent": "multAI-Backend/1.0",
        }

        html_content = f"""
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Bienvenue sur multAI !</h2>
            <p>Voici votre code de vérification :</p>
            <h1 style="background: #f4f4f4; padding: 10px; letter-spacing: 5px; text-align: center;">{otp}</h1>
            <p>Ce code est valide pendant 10 minutes.</p>
        </div>
        """

        data = {
            "from": settings.EMAIL_FROM,
            "to": [to_email],
            "subject": "Votre code de vérification multAI",
            "html": html_content,
            "category": "transactional",
        }

        req = urllib.request.Request(
            url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST"
        )

        def _send() -> bool:
            try:
                with urllib.request.urlopen(req, timeout=10) as response:
                    result = json.loads(response.read() or b"{}")
                if not result.get("accepted"):
                    logger.error(
                        "Email API accepted no recipient (suppressed earlier)"
                    )
                    return False
                logger.info("Email accepted by the email API: %s", result.get("message_id"))
                return True
            except urllib.error.HTTPError as e:
                logger.error(
                    "Email API refused the message: HTTP %s (%s)",
                    e.code,
                    EmailSender._error_code(e.read()),
                )
                return False
            except Exception as e:
                logger.error("Error sending email: %s", type(e).__name__)
                return False

        return await asyncio.to_thread(_send)
