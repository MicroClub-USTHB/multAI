import { createFileRoute } from '@tanstack/react-router';
import { allBlogs } from 'content-collections';

import { env } from '@/env';

export const Route = createFileRoute('/rss.xml')({
  server: {
    handlers: {
      GET: () => {
        const posts = Array.from(
          new Map(
            [...allBlogs]
              .sort(
                (a, b) =>
                  new Date(b.pubDate).valueOf() - new Date(a.pubDate).valueOf(),
              )
              .map((post) => [post.slug, post]),
          ).values(),
        );

        const items = posts
          .map((post) => {
            const url = `${env.VITE_SITE_URL}/blog/${post.slug}`;
            return `<item><title><![CDATA[${post.title}]]></title><description><![CDATA[${post.description}]]></description><link>${url}</link><guid>${url}</guid><pubDate>${new Date(post.pubDate).toUTCString()}</pubDate></item>`;
          })
          .join('');

        const xml = `<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title><![CDATA[${env.VITE_APP_TITLE ?? 'MultAI'}]]></title><description><![CDATA[MultiAI RSS feed]]></description><link>${env.VITE_SITE_URL}</link>${items}</channel></rss>`;

        return new Response(xml, {
          headers: {
            'Content-Type': 'application/rss+xml; charset=utf-8',
          },
        });
      },
    },
  },
});
