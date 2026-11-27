import { useEffect, useRef } from 'react';

const BLOB =
  'M158.332 60.2648C150.642 52.6552 140.08 47.9586 128.424 47.9586C111.779 47.9586 97.365 57.5359 90.3594 71.4962C73.8354 77.3698 62 93.1844 62 111.772C62 119.604 64.1015 126.944 67.7698 133.255C67.4328 135.42 67.2578 137.639 67.2578 139.899C67.2578 163.491 86.3254 182.617 109.846 182.617C110.271 182.617 110.694 182.61 111.116 182.598C117.944 187.269 126.196 190 135.084 190C149.63 190 162.472 182.686 170.155 171.524C188.046 166.462 201.157 149.97 201.157 130.406C201.157 125.61 200.369 120.998 198.916 116.694C200.369 112.39 201.157 107.778 201.157 102.982C201.157 79.3896 182.09 60.2641 158.569 60.2641L158.478 60.2643L158.332 60.2648Z';

/** MultiAI blob mascot. Eyes follow the cursor. */
export function Mascot({ className }: { className?: string }) {
  const face = useRef<SVGGElement>(null);
  const pupilL = useRef<SVGPathElement>(null);
  const pupilR = useRef<SVGPathElement>(null);
  const svg = useRef<SVGSVGElement>(null);

  useEffect(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    let raf = 0;
    const onMove = (e: PointerEvent) => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => {
        const el = svg.current;
        if (!el) return;
        const r = el.getBoundingClientRect();
        const dx = e.clientX - (r.left + r.width / 2);
        const dy = e.clientY - (r.top + r.height / 2);
        const dist = Math.hypot(dx, dy) || 1;
        const k = Math.min(dist / 260, 1); // ease in near the mascot
        const ux = (dx / dist) * k;
        const uy = (dy / dist) * k;
        // whole face leans a little, pupils travel further
        face.current?.style.setProperty('transform', `translate(${ux * 5}px, ${uy * 4}px)`);
        const p = `translate(${ux * 5}px, ${uy * 6 - 4}px)`;
        pupilL.current?.style.setProperty('transform', p);
        pupilR.current?.style.setProperty('transform', p);
      });
    };
    window.addEventListener('pointermove', onMove);
    return () => {
      window.removeEventListener('pointermove', onMove);
      cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <svg
      ref={svg}
      viewBox='58 43 148 152'
      fill='none'
      aria-hidden
      className={className}
    >
      <defs>
        <radialGradient id='mascot-body' cx='0.32' cy='0.28' r='0.9'>
          <stop offset='0' stopColor='#F4F5FF' />
          <stop offset='0.55' stopColor='#D9DDFF' />
          <stop offset='1' stopColor='#8E94E8' />
        </radialGradient>
      </defs>
      <path d={BLOB} fillRule='evenodd' fill='url(#mascot-body)' />
      <g ref={face} style={{ transition: 'transform 120ms ease-out' }}>
        <ellipse cx='142.02' cy='117.84' rx='14.39' ry='20.29' transform='rotate(-11.26 142.02 117.84)' fill='#00012C' />
        <ellipse cx='166.31' cy='118.58' rx='9.57' ry='18.75' transform='rotate(3.32 166.31 118.58)' fill='#00012C' />
        <g style={{ transform: 'translate(0,0)' }}>
          <ellipse cx='142.02' cy='117.84' rx='12' ry='18' transform='rotate(-11.26 142.02 117.84)' fill='#F9FAFF' />
          <ellipse cx='166.31' cy='118.58' rx='7.6' ry='16.6' transform='rotate(3.32 166.31 118.58)' fill='#F9FAFF' />
        </g>
        <path
          ref={pupilL}
          style={{ transition: 'transform 90ms ease-out' }}
          d='M149.098 130.526C151.323 130.526 153.128 127.902 153.128 124.665C153.128 123.898 153.026 123.165 152.842 122.493C152.194 122.938 151.409 123.199 150.563 123.199C148.635 123.199 147.022 121.844 146.626 120.035C145.678 121.107 145.068 122.782 145.068 124.665C145.068 127.902 146.872 130.526 149.098 130.526Z'
          fill='#00012C'
        />
        <path
          ref={pupilR}
          style={{ transition: 'transform 90ms ease-out' }}
          d='M163.752 130.76C165.977 130.76 167.782 128.135 167.782 124.898C167.782 124.131 167.68 123.398 167.496 122.727C166.848 123.172 166.063 123.433 165.217 123.433C163.289 123.433 161.676 122.078 161.28 120.268C160.332 121.341 159.722 123.016 159.722 124.898C159.722 128.135 161.526 130.76 163.752 130.76Z'
          fill='#00012C'
        />
      </g>
    </svg>
  );
}
