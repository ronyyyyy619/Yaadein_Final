import * as React from "react"
import { motion } from "framer-motion"
import { cn } from "../../lib/utils"
import { DivideIcon as LucideIcon } from "lucide-react"

interface DockProps {
  className?: string
  items: {
    icon: LucideIcon
    label: string
    onClick?: () => void
    className?: string
  }[]
}

interface DockIconButtonProps {
  icon: LucideIcon
  label: string
  onClick?: () => void
  className?: string
}

const floatingAnimation = {
  initial: { y: 0 },
  animate: {
    y: [-2, 2, -2],
    transition: {
      duration: 4,
      repeat: Infinity,
      ease: "easeInOut"
    }
  }
}

const DockIconButton = React.forwardRef<HTMLButtonElement, DockIconButtonProps>(
  ({ icon: Icon, label, onClick, className }, ref) => {
    return (
      <motion.button
        ref={ref}
        whileHover={{ scale: 1.1, y: -2 }}
        whileTap={{ scale: 0.95 }}
        onClick={onClick}
        className={cn(
          "relative group p-3 rounded-lg",
          "hover:bg-sage-100 transition-colors",
          className
        )}
      >
        <Icon className={cn("w-5 h-5 text-gray-700", className?.includes("bg-sage-700") ? "text-white" : "")} />
        <span className={cn(
          "absolute -top-8 left-1/2 -translate-x-1/2",
          "px-2 py-1 rounded text-xs",
          "bg-white text-gray-800 shadow-md",
          "opacity-0 group-hover:opacity-100",
          "transition-opacity whitespace-nowrap pointer-events-none"
        )}>
          {label}
        </span>
      </motion.button>
    )
  }
)
DockIconButton.displayName = "DockIconButton"

const Dock = React.forwardRef<HTMLDivElement, DockProps>(
  ({ items, className }, ref) => {
    return (
      <div ref={ref} className={cn("w-full flex items-center justify-center p-2 fixed bottom-0 left-0 right-0 z-50", className)}>
        <div className="w-full max-w-4xl flex items-center justify-center relative">
          <motion.div
            initial="initial"
            animate="animate"
            variants={floatingAnimation}
            className={cn(
              "flex items-center gap-1 p-2 rounded-2xl",
              "backdrop-blur-lg border shadow-lg",
              "bg-white/90 border-gray-200",
              "hover:shadow-xl transition-shadow duration-300"
            )}
          >
            {items.map((item) => (
              <DockIconButton key={item.label} {...item} />
            ))}
          </motion.div>
        </div>
      </div>
    )
  }
)
Dock.displayName = "Dock"

export { Dock }