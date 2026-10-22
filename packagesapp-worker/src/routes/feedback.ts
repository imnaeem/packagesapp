import { Hono, Context } from 'hono';
import { Env } from '../types/env';
import { FeedbackRow } from '../types/feedback';
import { FeedbackInputSchema } from '../schemas/feedback.schema';
import { formatFeedback } from '../utils/formatter';

export const feedbackRouter = new Hono<{ Bindings: Env }>();

/**
 * Common handler for processing feedback and contact submissions with Techshiner notifications.
 */
export async function processInquiry(c: Context<{ Bindings: Env }>, defaultType: 'feedback' | 'contact') {
  try {
    const rawBody = await c.req.json().catch(() => null);
    if (!rawBody) {
      return c.json({ success: false, error: 'Invalid or empty JSON body' }, 400);
    }

    const validation = FeedbackInputSchema.safeParse(rawBody);
    if (!validation.success) {
      return c.json(
        {
          success: false,
          error: 'Validation failed',
          issues: validation.error.issues,
        },
        400
      );
    }

    const data = validation.data;
    const feedbackId = crypto.randomUUID();
    const nowIso = new Date().toISOString();
    const inquiryType = data.type && data.type !== 'feedback' ? data.type : defaultType;

    const insertSql = `
      INSERT INTO feedback (id, user_id, name, email, subject, rating, category, message, type, status, device_info, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?);
    `;

    await c.env.DB.prepare(insertSql)
      .bind(
        feedbackId,
        data.userId || null,
        data.name || null,
        data.email || '',
        data.subject || null,
        data.rating,
        data.category,
        data.message,
        inquiryType,
        data.deviceInfo || null,
        nowIso
      )
      .run();

    // Notify Techshiner via Resend Email API if configured
    if (c.env.RESEND_API_KEY) {
      const supportEmail = c.env.SUPPORT_EMAIL || 'support@techshiner.com';
      const infoEmail = c.env.INFO_EMAIL || 'info@techshiner.com';

      const emailPayload = {
        from: 'Techshiner Packages App <onboarding@resend.dev>',
        to: [supportEmail, infoEmail],
        subject: `[Techshiner.com] New ${inquiryType.toUpperCase()}: ${data.subject || data.message.slice(0, 40)}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
            <div style="background: #00A0E3; padding: 16px; border-radius: 8px 8px 0 0; color: white;">
              <h2 style="margin: 0;">New ${inquiryType.toUpperCase()} Received</h2>
              <p style="margin: 4px 0 0 0; font-size: 13px; opacity: 0.9;">techshiner.com - Pakistan Mobile Packages API</p>
            </div>
            <div style="border: 1px solid #e0e0e0; border-top: none; padding: 20px; border-radius: 0 0 8px 8px; background: #fff;">
              <p><strong>Name:</strong> ${data.name || 'Not provided'}</p>
              <p><strong>Email:</strong> ${data.email || 'Not provided'}</p>
              <p><strong>Subject:</strong> ${data.subject || 'N/A'}</p>
              <p><strong>Rating:</strong> ${data.rating} / 5</p>
              <p><strong>Category:</strong> ${data.category}</p>
              <p><strong>Type:</strong> ${inquiryType}</p>
              <div style="margin-top: 16px;">
                <strong>Message:</strong>
                <div style="background: #f8f9fa; border-left: 4px solid #00A0E3; padding: 12px 16px; margin-top: 6px; border-radius: 4px; white-space: pre-wrap;">
                  ${data.message}
                </div>
              </div>
              <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
              <p style="font-size: 11px; color: #888; margin: 0;">ID: ${feedbackId} | Date: ${nowIso}</p>
            </div>
          </div>
        `,
      };

      try {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${c.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(emailPayload),
        });
      } catch (emailErr) {
        console.error('Failed to deliver email via Resend API:', emailErr);
      }
    } else {
      console.log(`[Techshiner Inquiry Received] ID: ${feedbackId}, Type: ${inquiryType}, Sender: ${data.name} (${data.email})`);
    }

    const row = await c.env.DB.prepare('SELECT * FROM feedback WHERE id = ?;')
      .bind(feedbackId)
      .first<FeedbackRow>();

    return c.json(
      {
        success: true,
        message:
          inquiryType === 'contact'
            ? 'Thank you for contacting Techshiner! Your message has been received.'
            : 'Feedback submitted successfully. Thank you for helping us improve!',
        feedback: row ? formatFeedback(row) : null,
      },
      201
    );
  } catch (error: any) {
    return c.json(
      {
        success: false,
        error: error?.message || 'Failed to submit inquiry',
      },
      500
    );
  }
}

feedbackRouter.post('/', async (c) => {
  return processInquiry(c, 'feedback');
});
