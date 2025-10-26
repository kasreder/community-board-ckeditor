import sanitizeHtml from 'sanitize-html';

const allowedTags = [
  'p',
  'span',
  'a',
  'img',
  'ul',
  'ol',
  'li',
  'strong',
  'em',
  'blockquote',
  'code',
  'pre',
  'table',
  'thead',
  'tbody',
  'tr',
  'td',
  'th',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'figure',
  'figcaption',
  'u',
  's',
  'div',
];

const allowedAttributes = {
  a: ['href', 'target', 'rel'],
  img: ['src', 'alt', 'width', 'height', 'style'],
  span: ['style'],
  '*': ['class', 'style'],
};

export const sanitizeRichText = (html) =>
  sanitizeHtml(html, {
    allowedTags,
    allowedAttributes,
    transformTags: {
      a: sanitizeHtml.simpleTransform('a', { rel: 'noopener noreferrer' }),
    },
  });

export default sanitizeRichText;
