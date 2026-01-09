# Form Components Reference

Comprehensive guide to all form components in Gluestack UI v2. These components handle user input with accessibility, validation, and customization built-in.

## Button

Versatile button component with multiple variants, sizes, and states.

### Basic Usage

```typescript
import { Button, ButtonText, ButtonIcon, ButtonSpinner } from '@/components/ui/button';
import { AddIcon } from '@gluestack-ui/themed';

// Solid button (default)
<Button variant="solid" size="md" onPress={() => console.log('Pressed')}>
  <ButtonText>Solid Button</ButtonText>
</Button>

// Outline button
<Button variant="outline">
  <ButtonText>Outline Button</ButtonText>
</Button>

// Link button
<Button variant="link">
  <ButtonText>Link Button</ButtonText>
</Button>
```

### Variants

```typescript
// Solid (default) - Filled background
<Button variant="solid">
  <ButtonText>Solid</ButtonText>
</Button>

// Outline - Border with transparent background
<Button variant="outline">
  <ButtonText>Outline</ButtonText>
</Button>

// Link - No background or border
<Button variant="link">
  <ButtonText>Link</ButtonText>
</Button>
```

### Sizes

```typescript
<Button size="xs"><ButtonText>Extra Small</ButtonText></Button>
<Button size="sm"><ButtonText>Small</ButtonText></Button>
<Button size="md"><ButtonText>Medium</ButtonText></Button>
<Button size="lg"><ButtonText>Large</ButtonText></Button>
<Button size="xl"><ButtonText>Extra Large</ButtonText></Button>
```

### With Icons

```typescript
import { AddIcon, EditIcon, TrashIcon } from '@gluestack-ui/themed';

// Icon before text
<Button>
  <ButtonIcon as={AddIcon} />
  <ButtonText>Add Item</ButtonText>
</Button>

// Icon after text
<Button>
  <ButtonText>Edit</ButtonText>
  <ButtonIcon as={EditIcon} />
</Button>

// Icon only
<Button>
  <ButtonIcon as={TrashIcon} />
</Button>
```

### Loading State

```typescript
const [loading, setLoading] = useState(false);

<Button disabled={loading}>
  {loading && <ButtonSpinner />}
  <ButtonText>{loading ? 'Loading...' : 'Submit'}</ButtonText>
</Button>
```

### Disabled State

```typescript
<Button disabled>
  <ButtonText>Disabled Button</ButtonText>
</Button>

// Customize disabled styling
<Button disabled opacity={0.4}>
  <ButtonText>Custom Disabled</ButtonText>
</Button>
```

### Full Width

```typescript
<Button width="100%">
  <ButtonText>Full Width Button</ButtonText>
</Button>
```

### Custom Colors

```typescript
<Button bg="$red600">
  <ButtonText>Danger</ButtonText>
</Button>

<Button bg="$green600">
  <ButtonText>Success</ButtonText>
</Button>
```

## Input

Text input component with validation, icons, and slots.

### Basic Usage

```typescript
import { Input, InputField } from '@/components/ui/input';

const [text, setText] = useState('');

<Input>
  <InputField
    placeholder="Enter text"
    value={text}
    onChangeText={setText}
  />
</Input>
```

### Input Types

```typescript
// Text input
<Input>
  <InputField placeholder="Username" />
</Input>

// Email
<Input>
  <InputField
    placeholder="Email"
    keyboardType="email-address"
    autoCapitalize="none"
  />
</Input>

// Password
<Input>
  <InputField
    placeholder="Password"
    secureTextEntry
  />
</Input>

// Number
<Input>
  <InputField
    placeholder="Age"
    keyboardType="numeric"
  />
</Input>

// Phone
<Input>
  <InputField
    placeholder="Phone"
    keyboardType="phone-pad"
  />
</Input>
```

### With Icons

```typescript
import { Input, InputField, InputSlot, InputIcon } from '@/components/ui/input';
import { SearchIcon, EyeIcon, EyeOffIcon } from '@gluestack-ui/themed';

// Leading icon
<Input>
  <InputSlot pl="$3">
    <InputIcon as={SearchIcon} />
  </InputSlot>
  <InputField placeholder="Search..." />
</Input>

// Trailing icon (password toggle)
const [showPassword, setShowPassword] = useState(false);

<Input>
  <InputField
    placeholder="Password"
    secureTextEntry={!showPassword}
  />
  <InputSlot pr="$3" onPress={() => setShowPassword(!showPassword)}>
    <InputIcon as={showPassword ? EyeIcon : EyeOffIcon} />
  </InputSlot>
</Input>
```

### Validation with FormControl

```typescript
import { Input, InputField } from '@/components/ui/input';
import {
  FormControl,
  FormControlLabel,
  FormControlLabelText,
  FormControlHelper,
  FormControlHelperText,
  FormControlError,
  FormControlErrorText,
} from '@/components/ui/form-control';

const [email, setEmail] = useState('');
const [error, setError] = useState('');

const validateEmail = (text: string) => {
  setEmail(text);
  if (!text.includes('@')) {
    setError('Invalid email format');
  } else {
    setError('');
  }
};

<FormControl isInvalid={!!error} isRequired>
  <FormControlLabel>
    <FormControlLabelText>Email</FormControlLabelText>
  </FormControlLabel>
  <Input>
    <InputField
      placeholder="your@email.com"
      value={email}
      onChangeText={validateEmail}
      keyboardType="email-address"
    />
  </Input>
  <FormControlHelper>
    <FormControlHelperText>
      We'll never share your email
    </FormControlHelperText>
  </FormControlHelper>
  {error && (
    <FormControlError>
      <FormControlErrorText>{error}</FormControlErrorText>
    </FormControlError>
  )}
</FormControl>
```

### Sizes

```typescript
<Input size="sm">
  <InputField placeholder="Small" />
</Input>

<Input size="md">
  <InputField placeholder="Medium (default)" />
</Input>

<Input size="lg">
  <InputField placeholder="Large" />
</Input>
```

### Disabled State

```typescript
<Input isDisabled>
  <InputField placeholder="Disabled input" />
</Input>
```

### Read-Only

```typescript
<Input isReadOnly>
  <InputField value="Read-only value" />
</Input>
```

## Checkbox

Checkbox component with support for controlled state, indeterminate, and groups.

### Basic Usage

```typescript
import { Checkbox, CheckboxIndicator, CheckboxIcon, CheckboxLabel } from '@/components/ui/checkbox';
import { CheckIcon } from '@gluestack-ui/themed';

const [checked, setChecked] = useState(false);

<Checkbox value="agree" isChecked={checked} onChange={setChecked}>
  <CheckboxIndicator>
    <CheckboxIcon as={CheckIcon} />
  </CheckboxIndicator>
  <CheckboxLabel>I agree to terms and conditions</CheckboxLabel>
</Checkbox>
```

### Uncontrolled Checkbox

```typescript
<Checkbox value="newsletter">
  <CheckboxIndicator>
    <CheckboxIcon as={CheckIcon} />
  </CheckboxIndicator>
  <CheckboxLabel>Subscribe to newsletter</CheckboxLabel>
</Checkbox>
```

### Indeterminate State

```typescript
const [childrenChecked, setChildrenChecked] = useState([false, false, false]);
const allChecked = childrenChecked.every(Boolean);
const isIndeterminate = childrenChecked.some(Boolean) && !allChecked;

<Checkbox
  isChecked={allChecked}
  isIndeterminate={isIndeterminate}
  onChange={(checked) => setChildrenChecked([checked, checked, checked])}
>
  <CheckboxIndicator>
    <CheckboxIcon as={CheckIcon} />
  </CheckboxIndicator>
  <CheckboxLabel>Select All</CheckboxLabel>
</Checkbox>
```

### Checkbox Group

```typescript
const [selectedValues, setSelectedValues] = useState<string[]>([]);

const options = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'angular', label: 'Angular' },
];

<VStack space="md">
  {options.map((option) => (
    <Checkbox
      key={option.value}
      value={option.value}
      isChecked={selectedValues.includes(option.value)}
      onChange={(checked) => {
        if (checked) {
          setSelectedValues([...selectedValues, option.value]);
        } else {
          setSelectedValues(selectedValues.filter(v => v !== option.value));
        }
      }}
    >
      <CheckboxIndicator>
        <CheckboxIcon as={CheckIcon} />
      </CheckboxIndicator>
      <CheckboxLabel>{option.label}</CheckboxLabel>
    </Checkbox>
  ))}
</VStack>
```

### Sizes

```typescript
<Checkbox size="sm"><CheckboxIndicator><CheckboxIcon as={CheckIcon} /></CheckboxIndicator><CheckboxLabel>Small</CheckboxLabel></Checkbox>
<Checkbox size="md"><CheckboxIndicator><CheckboxIcon as={CheckIcon} /></CheckboxIndicator><CheckboxLabel>Medium</CheckboxLabel></Checkbox>
<Checkbox size="lg"><CheckboxIndicator><CheckboxIcon as={CheckIcon} /></CheckboxIndicator><CheckboxLabel>Large</CheckboxLabel></Checkbox>
```

### Disabled State

```typescript
<Checkbox isDisabled value="disabled">
  <CheckboxIndicator>
    <CheckboxIcon as={CheckIcon} />
  </CheckboxIndicator>
  <CheckboxLabel>Disabled checkbox</CheckboxLabel>
</Checkbox>
```

## Select

Select dropdown component with single and multi-select support.

### Basic Usage

```typescript
import {
  Select,
  SelectTrigger,
  SelectInput,
  SelectIcon,
  SelectPortal,
  SelectBackdrop,
  SelectContent,
  SelectDragIndicatorWrapper,
  SelectDragIndicator,
  SelectItem,
} from '@/components/ui/select';
import { ChevronDownIcon } from '@gluestack-ui/themed';

const [selected, setSelected] = useState('');

<Select selectedValue={selected} onValueChange={setSelected}>
  <SelectTrigger>
    <SelectInput placeholder="Select option" />
    <SelectIcon as={ChevronDownIcon} />
  </SelectTrigger>
  <SelectPortal>
    <SelectBackdrop />
    <SelectContent>
      <SelectDragIndicatorWrapper>
        <SelectDragIndicator />
      </SelectDragIndicatorWrapper>
      <SelectItem label="Option 1" value="option1" />
      <SelectItem label="Option 2" value="option2" />
      <SelectItem label="Option 3" value="option3" />
    </SelectContent>
  </SelectPortal>
</Select>
```

### With FormControl

```typescript
<FormControl>
  <FormControlLabel>
    <FormControlLabelText>Country</FormControlLabelText>
  </FormControlLabel>
  <Select selectedValue={country} onValueChange={setCountry}>
    <SelectTrigger>
      <SelectInput placeholder="Select country" />
      <SelectIcon as={ChevronDownIcon} />
    </SelectTrigger>
    <SelectPortal>
      <SelectBackdrop />
      <SelectContent>
        <SelectDragIndicatorWrapper>
          <SelectDragIndicator />
        </SelectDragIndicatorWrapper>
        <SelectItem label="United States" value="us" />
        <SelectItem label="Canada" value="ca" />
        <SelectItem label="Mexico" value="mx" />
      </SelectContent>
    </SelectPortal>
  </Select>
</FormControl>
```

### Disabled State

```typescript
<Select isDisabled>
  <SelectTrigger>
    <SelectInput placeholder="Disabled select" />
    <SelectIcon as={ChevronDownIcon} />
  </SelectTrigger>
</Select>
```

## Slider

Slider component for selecting numeric values.

### Basic Usage

```typescript
import {
  Slider,
  SliderTrack,
  SliderFilledTrack,
  SliderThumb,
} from '@/components/ui/slider';

const [value, setValue] = useState(50);

<Slider value={value} onChange={setValue} minValue={0} maxValue={100}>
  <SliderTrack>
    <SliderFilledTrack />
  </SliderTrack>
  <SliderThumb />
</Slider>
```

### With Label and Value Display

```typescript
<VStack space="md">
  <HStack justifyContent="space-between">
    <Text>Volume</Text>
    <Text>{value}%</Text>
  </HStack>
  <Slider value={value} onChange={setValue} minValue={0} maxValue={100}>
    <SliderTrack>
      <SliderFilledTrack />
    </SliderTrack>
    <SliderThumb />
  </Slider>
</VStack>
```

### Range Slider

```typescript
const [range, setRange] = useState([20, 80]);

<Slider value={range} onChange={setRange} minValue={0} maxValue={100}>
  <SliderTrack>
    <SliderFilledTrack />
  </SliderTrack>
  <SliderThumb />
  <SliderThumb />
</Slider>
```

### Step Values

```typescript
<Slider
  value={value}
  onChange={setValue}
  minValue={0}
  maxValue={100}
  step={10}
>
  <SliderTrack>
    <SliderFilledTrack />
  </SliderTrack>
  <SliderThumb />
</Slider>
```

## Switch

Toggle switch component for boolean values.

### Basic Usage

```typescript
import { Switch } from '@/components/ui/switch';

const [enabled, setEnabled] = useState(false);

<Switch value={enabled} onValueChange={setEnabled} />
```

### With Label

```typescript
<HStack space="md" alignItems="center">
  <Switch value={notifications} onValueChange={setNotifications} />
  <Text>Enable notifications</Text>
</HStack>
```

### Sizes

```typescript
<Switch size="sm" />
<Switch size="md" />
<Switch size="lg" />
```

### Disabled State

```typescript
<Switch isDisabled value={false} />
<Switch isDisabled value={true} />
```

### Custom Colors

```typescript
<Switch
  trackColor={{ false: '$gray300', true: '$green600' }}
  thumbColor="$white"
/>
```

## Textarea

Multi-line text input component.

### Basic Usage

```typescript
import { Textarea, TextareaInput } from '@/components/ui/textarea';

const [text, setText] = useState('');

<Textarea>
  <TextareaInput
    placeholder="Enter description"
    value={text}
    onChangeText={setText}
  />
</Textarea>
```

### With Character Count

```typescript
const [text, setText] = useState('');
const maxLength = 200;

<VStack space="xs">
  <Textarea>
    <TextareaInput
      placeholder="Enter description"
      value={text}
      onChangeText={setText}
      maxLength={maxLength}
    />
  </Textarea>
  <Text size="sm" color="$gray500">
    {text.length}/{maxLength} characters
  </Text>
</VStack>
```

### Auto-Resize

```typescript
<Textarea>
  <TextareaInput
    placeholder="Auto-resizing textarea"
    multiline
    numberOfLines={4}
  />
</Textarea>
```

### With Validation

```typescript
const [description, setDescription] = useState('');
const error = description.length < 10 ? 'Description must be at least 10 characters' : '';

<FormControl isInvalid={!!error}>
  <FormControlLabel>
    <FormControlLabelText>Description</FormControlLabelText>
  </FormControlLabel>
  <Textarea>
    <TextareaInput
      placeholder="Enter description"
      value={description}
      onChangeText={setDescription}
    />
  </Textarea>
  {error && (
    <FormControlError>
      <FormControlErrorText>{error}</FormControlErrorText>
    </FormControlError>
  )}
</FormControl>
```

### Disabled State

```typescript
<Textarea isDisabled>
  <TextareaInput placeholder="Disabled textarea" />
</Textarea>
```

## Best Practices

**Form Components:**
- Always use FormControl for validation and error display
- Provide clear labels and helper text
- Use appropriate keyboard types for mobile inputs
- Implement accessible focus states
- Show loading states for async operations
- Provide visual feedback on interactions
- Use compound components for flexibility
- Test with screen readers
- Implement proper error handling
- Use design tokens for consistent styling

**Performance:**
- Use controlled components only when necessary
- Debounce expensive validation operations
- Memoize expensive computations
- Avoid inline functions in render
- Use React.memo for static components

**Accessibility:**
- Always include accessible labels
- Provide error messages in FormControlError
- Use appropriate ARIA attributes
- Support keyboard navigation
- Ensure sufficient color contrast
- Test with screen readers
